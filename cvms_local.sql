PGDMP  (    0                |            cvms_new    16.0    16.0 �   d           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                      false            e           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                      false            f           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                      false            g           1262    18424    cvms_new    DATABASE     {   CREATE DATABASE cvms_new WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'English_India.1252';
    DROP DATABASE cvms_new;
                postgres    false                        2615    18425    public    SCHEMA     2   -- *not* creating schema, since initdb creates it
 2   -- *not* dropping schema, since initdb creates it
                postgres    false            h           0    0    SCHEMA public    ACL     +   REVOKE USAGE ON SCHEMA public FROM PUBLIC;
                   postgres    false    5            G           1255    18426 ,   addDistrib(json, integer, character varying)    FUNCTION     S  CREATE FUNCTION public."addDistrib"(data json, usid integer, pswd character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
DECLARE
  userid integer;
  vname varchar;
  vemail varchar;
BEGIN
  
  INSERT INTO userinfo(name,email,pwd,mobile,address,addedBy,active,manuf_id,user_type) 
					 VALUES(data->>'cperson',data->>'mail',pswd,data->>'mob',
                     data->>'addr',usid,'t',usid,'DR') returning id,name,email 
                    INTO  userid,vname,vemail;
  insert into user_roles(user_id,role_id,active,default_role,addedby) values(userid,6,'t','t',usid);
  INSERT INTO channel_partner(user_id, company_name, active, added_by, gst_no,district,state) 
  VALUES (userid,data->>'cname','t',usid,data->>'gst',(data->>'distr')::integer,(data->>'state')::integer);
  
  return TRUE;
  
EXCEPTION
WHEN OTHERS THEN
  RAISE;
END;
$$;
 T   DROP FUNCTION public."addDistrib"(data json, usid integer, pswd character varying);
       public          postgres    false    5            s           1255    18427 m  add_device_owner(character varying, character varying, character varying, character varying, character varying, character varying, integer, integer, integer, integer, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, integer, character varying, character varying)    FUNCTION     �  CREATE FUNCTION public.add_device_owner(own_mob character varying, own_name character varying, own_pwd character varying, own_mail character varying, own_addr character varying, tenantid character varying, manufid integer, userid integer, distrid integer, francid integer, regno character varying, imei_no character varying, vehtype character varying, metering_type character varying, start_date character varying, end_date character varying, status character varying, entitytype character varying, sub_period integer, sim1 character varying, sim2 character varying) RETURNS json
    LANGUAGE plpgsql
    AS $$
DECLARE
  count integer;
  veh_owner_id integer;
  userType varchar;
  owner_user_id integer;
  vehId integer;
  vehNo varchar;
  entityId varchar;
  devcnt integer;
BEGIN
  SELECT COUNT(*) into count FROM veh_info WHERE veh_no=regNo or imei=imei_no;
  if count >0 then
      RAISE EXCEPTION 'DUPLICATE'
      USING HINT = 'DUPLICATE';
  else
    select count(*) into devcnt from device_details where imei=imei_no;
	IF devcnt=0 then 
	 	 RAISE EXCEPTION 'NOLIC'
      	 USING HINT = 'NOLIC';
		 --return '{"message":"Error Saving Record! No Subscription Balance"}';
	END IF;
	SELECT id, user_type INTO veh_owner_id, userType FROM userinfo WHERE mobile=own_mob AND manuf_id=manufId;
	--AND   distr_id=distrId AND franc_id=francId;
	if veh_owner_id is null then
		INSERT INTO userinfo(id, name, email, pwd, mobile, active, address, tenentid, addedby, manuf_id, distr_id, franc_id,image_url,user_type)
		  VALUES(default,own_name,own_mail,own_pwd,own_mob,'t',own_addr,tenantId,userId,manufId,distrId,francId,'images/no-img.png','OW')
		  returning id into  veh_owner_id;
		insert into user_roles(user_id,role_id,active,default_role,addedby,id)
		  values(veh_owner_id,3,'t','t',userId,default);
	end if;
	INSERT INTO veh_info(veh_no,imei,veh_type,dev_manuf_id,dev_distr_id,dev_franc_id)
		VALUES (regNo,imei_no,vehtype,manufId,distrId,francId) returning veh_id,veh_no INTO vehId,vehNo;
	INSERT INTO user_veh(userid,vehid) VALUES(veh_owner_id,vehId);
	INSERT INTO subscription_details(user_id,entity_id,metering_type,start_date,end_date,status,entity_type,manuf_id,distr_id,franc_id,sub_period)
		VALUES(veh_owner_id,imei_no,metering_type,to_date(start_date,'yyyy-MM-dd'),to_date(end_date,'yyyy-MM-dd'),status,entityType,manufId,distrId,francId,sub_period)
		returning entity_id into entityId;
    select count(*) into devcnt from device_details where imei_no=imei;
	IF devcnt=0 then 
	 INSERT INTO device_details(imei,sim_no,sim_no2) VALUES(imei_no,sim1,sim2);
	ELSE
	 UPDATE device_details SET sim_no=sim1,sim_no2=sim2 where imei_no=imei;
	END IF;
	if entityId is not null then
	   INSERT INTO mob_vehicle_map (mobno,veh_no,imei,owner_id,exp_date,owner_type)
			VALUES (own_mob,regNo,imei_no,veh_owner_id,to_date(end_date,'yyyy-MM-dd'),'OW');
	end if;
    return '{"message":"Vehicle & Owner Details Saved Successfully "}';
  end if;
EXCEPTION
WHEN OTHERS THEN
  RAISE;
 return '{"message":"Error Saving Record"}';
END;
$$;
 6  DROP FUNCTION public.add_device_owner(own_mob character varying, own_name character varying, own_pwd character varying, own_mail character varying, own_addr character varying, tenantid character varying, manufid integer, userid integer, distrid integer, francid integer, regno character varying, imei_no character varying, vehtype character varying, metering_type character varying, start_date character varying, end_date character varying, status character varying, entitytype character varying, sub_period integer, sim1 character varying, sim2 character varying);
       public          postgres    false    5            i           0    0 (  FUNCTION add_device_owner(own_mob character varying, own_name character varying, own_pwd character varying, own_mail character varying, own_addr character varying, tenantid character varying, manufid integer, userid integer, distrid integer, francid integer, regno character varying, imei_no character varying, vehtype character varying, metering_type character varying, start_date character varying, end_date character varying, status character varying, entitytype character varying, sub_period integer, sim1 character varying, sim2 character varying)    ACL     M  REVOKE ALL ON FUNCTION public.add_device_owner(own_mob character varying, own_name character varying, own_pwd character varying, own_mail character varying, own_addr character varying, tenantid character varying, manufid integer, userid integer, distrid integer, francid integer, regno character varying, imei_no character varying, vehtype character varying, metering_type character varying, start_date character varying, end_date character varying, status character varying, entitytype character varying, sub_period integer, sim1 character varying, sim2 character varying) FROM postgres;
          public          postgres    false    371            Z           1255    18428    add_iccid(json)    FUNCTION     �  CREATE FUNCTION public.add_iccid(iccdat json) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
DECLARE
  --i json;
  imcnt integer;
  slCode varchar(20);
  btch numeric;
  slNumber numeric;
  simno varchar(40);
  simno1 varchar(40);
  tenantid integer;
  hwtype varchar;
  hwtypeid integer;
  avl_license_sw integer;
  avl_license_hw integer;
  license_id_hw integer;
  license_id_sw integer;
BEGIN
    
	hwtype:=iccDat->>'typ';
	tenantid:=(iccDat->>'tnt')::integer;
	select count(*) into imcnt from device_details where imei=iccDat->>'imei';
	if imcnt>0 and hwtype='T2' then
		delete from device_details where imei=iccDat->>'imei' and dev_type IS NULL and hw_license_id IS NULL and sw_license_id IS NULL;
	end if;
	select count(*) into imcnt from device_details where imei=iccDat->>'imei';
	if imcnt>0 then
	  --ICCID is updated to get the updated iccid when sim is replaced
	  update device_details SET  iccid=iccDat->>'iccid',restart_cnt=(COALESCE(restart_cnt,0)+1),last_restart_date=now() where imei=iccDat->>'imei';
	  RETURN TRUE;
	else
		/*Check for Subscription*/
		IF hwtype IS NOT NULL THEN
		   select id into hwtypeid from fin.license_types where type=hwtype;
		   --update fin.license_details set license=license-1 where tenant_id=tenantid and license_type=hwtypeid RETURNING license INTO avl_license_hw;
		ELSE
		   hwtypeid:=1;
		   --update fin.license_details set license=license-1 where tenant_id=tenantid and license_type=1 RETURNING license INTO avl_license_hw;
		END IF;
		
		--update fin.license_details set license=license-1 where tenant_id=tenantid and license_type=3 RETURNING license INTO avl_license_sw;
		select license,id INTO avl_license_hw,license_id_hw FROM  fin.license_details  where tenant_id=tenantid and license_type=hwtypeid and license>0 limit 1;
		select license,id INTO avl_license_sw,license_id_sw FROM  fin.license_details  where tenant_id=tenantid and license_type=3 and license>0 limit 1;
		IF ((avl_license_hw IS NOT NULL) AND (avl_license_sw IS NOT NULL)) THEN 
			update fin.license_details set license=license-1 where id=license_id_hw RETURNING license INTO avl_license_hw;
			update fin.license_details set license=license-1 where id=license_id_sw RETURNING license INTO avl_license_sw;
			IF ((avl_license_hw IS NOT NULL) AND (avl_license_sw IS NOT NULL) AND (avl_license_hw > -1) AND (avl_license_sw > -1)) THEN 
				select batch,slno into btch,slNumber from product_master where product='01';
    			if slNumber<5000 then
       				update product_master set slno=slno+1  where product='01' returning LPAD(to_char(now(),'yy'), 2, '0')||LPAD(to_char(now(),'mm'), 2, '0')||product||pcb||ems||LPAD(batch::text, 3, '0')||LPAD(slno::text, 4, '0') into slCode;
    			else
      				update product_master set batch=batch+1,slno=1  where product='01' returning LPAD(to_char(now(),'yy'), 2, '0')||LPAD(to_char(now(),'mm'), 2, '0')||product||pcb||ems||LPAD(batch::text, 3, '0')||LPAD(slno::text, 4, '0') into slCode;
   				end if;
            	--SELECT COALESCE(msisdn1,''),COALESCE(msisdn2,'')  into simno,simno1 FROM  sim_data where iccid1=iccDat->>'iccid';
         		--INSERT INTO vlt_details(imei,iccid) VALUES(cast(iccDat->>'imei' as numeric), iccDat->>'ICC');
				select COALESCE(sd1.msisdn,''),COALESCE(sd2.msisdn,'') into simno,simno1 
					from mcsa.sim_details sd1 left  join mcsa.sim_details sd2 
						on (sd1.stk_id=sd2.stk_id and sd1.lot_id=sd2.lot_id and sd1.sim_id=sd2.sim_id and sd1.iccid!=sd2.iccid)
  					where sd1.iccid=iccDat->>'iccid' and sd1.msisdn IS NOT NULL and sd2.msisdn IS NOT NULL;
         		INSERT INTO device_details(imei,iccid,serial_number,manufact_date,sim_no,sim_no2,dev_type,hw_license_id,sw_licenseid) 
		 		VALUES(iccDat->>'imei', iccDat->>'iccid',slCode,now(),simno,simno1,hwtype,license_id_hw,license_id_sw::varchar);
				RETURN TRUE;
			ELSE
				RETURN FALSE;
			END IF;
		ELSE
		    RETURN FALSE;
	   END IF;
	end if;
    

  return 'TRUE';

EXCEPTION WHEN OTHERS THEN
   RAISE;
   return 'FALSE';
END;
$$;
 -   DROP FUNCTION public.add_iccid(iccdat json);
       public          postgres    false    5            [           1255    18429    add_serialnum(json)    FUNCTION     �  CREATE FUNCTION public.add_serialnum(iccdat json) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
DECLARE


slCode varchar(20);


btch numeric;


slNumber numeric;


BEGIN

--select sl_no into slCode from vlt_details WHERE imei=(iccDat->>'imei')::numeric;

--if slCode is null then 

	select batch,slno into btch,slNumber from product_master where product=iccDat->>'product';
	if slNumber<2000 then
       update product_master set slno=slno+1 where product=iccDat->>'product' returning
        LPAD(extract(year from now())::text, 4, '0')||LPAD(extract(month from now())::text,
        2, '0')||product||pcb||ems||LPAD(batch::text, 3, '0')||LPAD(slno::text, 4, '0') into
        slCode;

    else
		update product_master set batch=batch+1,slno=1 where product=iccDat->>'product'
		returning LPAD(extract(year from now())::text, 4, '0')||LPAD(extract(month from
		now())::text, 2, '0')||product||pcb||ems||LPAD(batch::text, 3,
		'0')||LPAD(slno::text, 4, '0') into slCode;


	end if;

	UPDATE vlt_details SET sl_no=slCode WHERE imei=(iccDat->>'imei')::numeric;

--end if;
 


return slCode;




EXCEPTION WHEN OTHERS THEN
return 0;




        


 


END;
$$;
 1   DROP FUNCTION public.add_serialnum(iccdat json);
       public          postgres    false    5            ]           1255    18430 $   adminstockallocate(integer, integer)    FUNCTION     �  CREATE FUNCTION public.adminstockallocate(groupingrange integer, dealeruserid integer) RETURNS bigint[]
    LANGUAGE plpgsql
    AS $$
DECLARE
  idGroup integer[];
  imeiGroup bigint[];
  startt integer;
  endd integer;
  availableCount integer;
  j json;
BEGIN

	SELECT count(*),array_agg(dd.id),array_agg(dd.imei) into availableCount,idGroup,imeiGroup FROM (SELECT * FRom device_details WHERE status='NEW' order by id ASC LIMIT groupingrange) as dd; 
    RAISE NOTICE 'result: (%)',idGroup;
    RAISE NOTICE 'available count: (%)',availableCount;
    RAISE NOTICE 'Required qty: (%)',groupingrange;
    
    IF groupingrange=availableCount THEN
    	
        startt:=idGroup[1];
        endd:=idGroup[array_upper(idGroup, 1)];
         
        RAISE NOTICE 'start: (%)',startt;
        RAISE NOTICE 'end: (%)',endd;
           
        INSERT INTO device_block(start, stop, count,dealer_userid,details)
        VALUES (startt,endd,availableCount,dealeruserid,imeiGroup);
           
        UPDATE device_details SET status='SUPPLIED' WHERE status='NEW' AND id between startt and endd;
           
           
           
        FOR j IN 1..array_upper(idGroup,1) LOOP
            RAISE NOTICE 'VALUE OF j:(%) ',j;
            INSERT INTO dealer_device(dealer_userid, device_id)
             VALUES (dealeruserid,idGroup[j]);
        END LOOP;     
   		RETURN imeiGroup;
      END IF;
	  RETURN null;
EXCEPTION
WHEN OTHERS THEN
  RAISE;
END;
$$;
 V   DROP FUNCTION public.adminstockallocate(groupingrange integer, dealeruserid integer);
       public          postgres    false    5            ^           1255    18431 K   changePwd(character varying, character varying, character varying, integer)    FUNCTION     �  CREATE FUNCTION public."changePwd"(cpwd character varying, npwd character varying, cnpwd character varying, userid integer) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
DECLARE
  curr_pwd varchar;
BEGIN
  select pwd from userinfo into curr_pwd where id=userid;
   IF cpwd=curr_pwd THEN 
       IF npwd=cnpwd THEN
       		UPDATE userinfo SET pwd=cnpwd where id=userid;
            RETURN TRUE;
       ELSE
       	RAISE EXCEPTION 'NEW PASSWORD & CONFIRMED PASSWORD ARE Different' USING HINT ='DIFF NEW PWD';
  	   END IF;
   ELSE
      RAISE EXCEPTION 'PASSWORD VALIDATION FAILED FOR USER' USING HINT ='WRONG PWD';
   END IF;
EXCEPTION
WHEN OTHERS THEN
  RAISE;
END;
$$;
 {   DROP FUNCTION public."changePwd"(cpwd character varying, npwd character varying, cnpwd character varying, userid integer);
       public          postgres    false    5            _           1255    18432 2   cpstockallocatetodealer(integer, integer, integer)    FUNCTION       CREATE FUNCTION public.cpstockallocatetodealer(groupingrange integer, dealeruserid integer, cpuserid integer) RETURNS bigint[]
    LANGUAGE plpgsql
    AS $$
DECLARE
  idGroup integer[];
  imeiGroup bigint[];
  startt integer;
  endd integer;
  availableCount integer;
  j json;
BEGIN

	SELECT count(*),array_agg(dd.id),array_agg(dd.imei) into availableCount,idGroup,imeiGroup FROM (SELECT d.id,d.imei from device_details d inner join cp_device cpd on cpd.device_id=d.id  WHERE d.status='CP' AND cpd.cp_userid=cpuserid order by id ASC LIMIT groupingrange) as dd; 
    RAISE NOTICE 'result: (%)',idGroup;
    RAISE NOTICE 'available count: (%)',availableCount;
    RAISE NOTICE 'Required qty: (%)',groupingrange;
    
    IF groupingrange=availableCount THEN
    	
        startt:=idGroup[1];
        endd:=idGroup[array_upper(idGroup, 1)];
         
        RAISE NOTICE 'start: (%)',startt;
        RAISE NOTICE 'end: (%)',endd;
           
        INSERT INTO device_block(start, stop, count,dealer_userid,details)
        VALUES (startt,endd,availableCount,dealeruserid,imeiGroup);
           
        UPDATE device_details SET status='SUPPLIED' WHERE status='CP' AND id between startt and endd;
           
           
           
        FOR j IN 1..array_upper(idGroup,1) LOOP
            RAISE NOTICE 'VALUE OF j:(%) ',j;
            INSERT INTO dealer_device(dealer_userid, device_id)
             VALUES (dealeruserid,idGroup[j]);
        END LOOP;     
   		RETURN imeiGroup;
      END IF;
	  RETURN null;
EXCEPTION
WHEN OTHERS THEN
  RAISE;
END;
$$;
 m   DROP FUNCTION public.cpstockallocatetodealer(groupingrange integer, dealeruserid integer, cpuserid integer);
       public          postgres    false    5            `           1255    18433    dealerdeviceadd(json, integer)    FUNCTION     �  CREATE FUNCTION public.dealerdeviceadd(arrayids json, userid integer) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
DECLARE
  i json;
  
BEGIN
  FOR i IN SELECT * FROM json_array_elements(arrayIds) LOOP
  	INSERT INTO dealer_device(dealer_userid, device_id) VALUES (userId,cast(i->>'id' as INTEGER));
  END LOOP;
  return 'TRUE';

EXCEPTION WHEN OTHERS THEN
   
  	RAISE ;
  	return 'FALSE';

  	
      
END;
$$;
 E   DROP FUNCTION public.dealerdeviceadd(arrayids json, userid integer);
       public          postgres    false    5            a           1255    18434    del_user(integer)    FUNCTION     �  CREATE FUNCTION public.del_user(uid integer) RETURNS json
    LANGUAGE plpgsql
    AS $$
DECLARE

BEGIN

IF (SELECT count(*) from  user_veh where userid=uid)>0 THEN
	RETURN '{"message":"Cannot delete user since vehicle(s) mapped to user."}';
ELSE
delete from  userinfo where id=uid;
delete from user_roles where user_id=uid;
return '{"message":"User Deleted"}';
END IF;

EXCEPTION
WHEN OTHERS THEN
  RAISE;
  return '{"message":"Error Saving Record"}';
END;
$$;
 ,   DROP FUNCTION public.del_user(uid integer);
       public          postgres    false    5            b           1255    18435 6   del_veh(character varying, character varying, integer)    FUNCTION     +  CREATE FUNCTION public.del_veh(imeino character varying, vehno character varying, loginuserid integer) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
DECLARE
   vvehid integer;
   vuserid integer;
   user_veh_cnt integer;
   user_role_cnt integer;
BEGIN

select veh_id into vvehid from veh_info where veh_no=vehno and imei=imeino and dev_manuf_id=loginuserid;
select userid into vuserid from user_veh where vehid=vvehid;
RAISE NOTICE 'vvehid  (%) ', vvehid;
RAISE NOTICE 'vuserid  (%) ', vuserid;

--veh_info
delete from veh_info where veh_id=vvehid;-- veh_no=vehno and imei=imeino and dev_manuf_id=loginuserid;

--user_veh
delete from user_veh where vehid=vvehid ;

--subscription_details
delete from subscription_details where entity_id=imeino and manuf_id=loginuserid;

--mob_vehicle_map
delete from mob_vehicle_map where imei=imeino and veh_no=vehno;


select count(*) into user_veh_cnt from user_veh where userid=vuserid;

RAISE NOTICE 'user_veh_cnt  (%) ', user_veh_cnt;

 IF user_veh_cnt=0  THEN 
--user_roles
   delete from user_roles where user_id=vuserid and role_id=3;
   select count(*) into user_role_cnt from user_roles where user_id=vuserid;
    IF user_role_cnt=0 THEN
--userinfo
   			delete from userinfo where id=vuserid;
	END IF;
 END IF;

   RETURN 'true';
EXCEPTION 
WHEN OTHERS THEN
 RAISE;
END;
$$;
 f   DROP FUNCTION public.del_veh(imeino character varying, vehno character varying, loginuserid integer);
       public          postgres    false    5            c           1255    18436 L   del_veh_old(character varying, character varying, integer, integer, integer)    FUNCTION     �  CREATE FUNCTION public.del_veh_old(imeino character varying, vehno character varying, manufid integer, distrid integer, francid integer) RETURNS boolean
    LANGUAGE plpgsql
    AS $$DECLARE
   vvehid integer;
   vuserid integer;
   user_veh_cnt integer;
   user_role_cnt integer;
BEGIN
--veh_info
delete from veh_info where veh_no=vehno and imei=imeino and dev_manuf_id=manufid and dev_distr_id=distrid and dev_franc_id=francid 
returning veh_id into vvehid;
--user_veh
delete from user_veh where vehid=vvehid returning userid into vuserid;
--subscription_details
delete from subscription_details where entity_id=imeino and manuf_id=manufid
and distr_id=distrid and franc_id=francid;

--mob_vehicle_map
delete from mob_vehicle_map where imei=imeino and veh_no=vehno;

select count(*) into user_veh_cnt from user_veh where userid=vuserid;
 IF user_veh_cnt=0 THEN 
   delete from user_roles where user_id=vuserid and role_id=3;
   select count(*) into user_role_cnt from user_roles where user_id=vuserid;
    IF user_role_cnt=0 THEN
   			delete from userinfo where id=vuserid;
	END IF;
 END IF;

   RETURN 'true';
EXCEPTION 
WHEN OTHERS THEN
 RAISE;
END;
$$;
 �   DROP FUNCTION public.del_veh_old(imeino character varying, vehno character varying, manufid integer, distrid integer, francid integer);
       public          postgres    false    5            F           1255    18437    deletedealer(integer)    FUNCTION     �  CREATE FUNCTION public.deletedealer(usid integer) RETURNS boolean
    LANGUAGE plpgsql
    AS $$DECLARE
  userid integer;
  vname varchar;
  vemail varchar;
  vehcnt integer;
  rolecnt integer;
BEGIN
  select count(*) into vehcnt from veh_info where dev_franc_id=usid;
  IF vehcnt>0 THEN
     RETURN FALSE;
  ELSE 
     select count(*) into rolecnt from user_roles where active='t' and id=usid;
	 IF rolecnt>1 THEN 
	 	RETURN FALSE;
	 ELSE
	   DELETE FROM dealer where user_id=usid;
	   DELETE FROM user_roles where user_id=usid;
	   DELETE FROM userinfo where id=usid;
       return TRUE;
	 END IF;
  END IF;

EXCEPTION WHEN OTHERS THEN
  RAISE;
END;
$$;
 1   DROP FUNCTION public.deletedealer(usid integer);
       public          postgres    false    5            H           1255    18438    deletedistrib(integer)    FUNCTION     �  CREATE FUNCTION public.deletedistrib(usid integer) RETURNS boolean
    LANGUAGE plpgsql
    AS $$DECLARE
  userid integer;
  vname varchar;
  vemail varchar;
  vehcnt integer;
  rolecnt integer;
BEGIN
  select count(*) into vehcnt from veh_info where dev_distr_id=usid;
  IF vehcnt>0 THEN
     RETURN FALSE;
  ELSE 
     select count(*) into rolecnt from user_roles where active='t' and id=usid;
	 IF rolecnt>1 THEN 
	 	RETURN FALSE;
	 ELSE
	   DELETE FROM channel_partner where user_id=usid;
	   DELETE FROM user_roles where user_id=usid;
	   DELETE FROM userinfo where id=usid;
       return TRUE;
	 END IF;
  END IF;

EXCEPTION WHEN OTHERS THEN
  RAISE;
END;$$;
 2   DROP FUNCTION public.deletedistrib(usid integer);
       public          postgres    false    5            I           1255    18439    device_activation(integer[])    FUNCTION     �  CREATE FUNCTION public.device_activation(imeiintarr integer[]) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
DECLARE
  --variable_name datatype;
  j integer;
BEGIN

	FOR j IN 1..array_upper(imeiintarr,1) LOOP
    	RAISE NOTICE 'VALUE OF j:(%) ',imeiintarr[j];
         UPDATE device_details SET status='ACTIVE' WHERE id=imeiintarr[j];
  	END LOOP;
	
	--FOR i IN SELECT * FROM json_array_elements(imeiintarr) LOOP
    --	RAISE NOTICE 'dssa (%)',i->>imei;
  	--	--INSERT INTO dealer_device(dealer_userid, device_id) VALUES (userId,cast(i->>'imei' as INTEGER));
  	--	UPDATE device_details SET status='ACTIVE' WHERE imei=i->>'imei';
   -- END LOOP;	

	
  		
	
RETURN TRUE;
EXCEPTION
WHEN OTHERS THEN
  RAISE;
END;
$$;
 >   DROP FUNCTION public.device_activation(imeiintarr integer[]);
       public          postgres    false    5            J           1255    18440    device_activation(bigint[])    FUNCTION     �  CREATE FUNCTION public.device_activation(imeiintarr bigint[]) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
DECLARE
  --variable_name datatype;
  j integer;
BEGIN

	FOR j IN 1..array_upper(imeiintarr,1) LOOP
    	--RAISE NOTICE 'VALUE OF j:(%) ',imeiintarr[j];
         UPDATE device_details SET status='ACTIVE' WHERE imei=CAST(imeiintarr[j] as varchar);
  	END LOOP;
	
	--FOR i IN SELECT * FROM json_array_elements(imeiintarr) LOOP
    --	RAISE NOTICE 'dssa (%)',i->>imei;
  	--	--INSERT INTO dealer_device(dealer_userid, device_id) VALUES (userId,cast(i->>'imei' as INTEGER));
  	--	UPDATE device_details SET status='ACTIVE' WHERE imei=i->>'imei';
   -- END LOOP;	

	
  		
	
RETURN TRUE;
EXCEPTION
WHEN OTHERS THEN
  RAISE;
END;
$$;
 =   DROP FUNCTION public.device_activation(imeiintarr bigint[]);
       public          postgres    false    5            K           1255    18441    get_dealer_names()    FUNCTION     [  CREATE FUNCTION public.get_dealer_names() RETURNS text
    LANGUAGE plpgsql
    AS $$

DECLARE 
 dealerNames TEXT DEFAULT '';
 rec_dealer   RECORD;
 -- Declare cursor
 cur_dealer CURSOR FOR SELECT * FROM dealer;
 
BEGIN
   -- Open the cursor
   OPEN cur_dealer;
 
   -- Loop through cursor
   LOOP
    -- fetch row into the rec_dealer
      FETCH cur_dealer INTO rec_dealer;
    -- exit when no more row to fetch
      EXIT WHEN NOT FOUND;
    -- output
        dealerNames := dealerNames || ',' || rec_dealer.dealer_name;
   END LOOP;
  
   -- Close the cursor
  
 
   RETURN dealerNames;
   
END; $$;
 )   DROP FUNCTION public.get_dealer_names();
       public          postgres    false    5            L           1255    18442 $   resetPwd(integer, character varying)    FUNCTION     �   CREATE FUNCTION public."resetPwd"(userid integer, newpwd character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
BEGIN
  UPDATE userinfo SET pwd=newpwd where id=userid;
  RETURN TRUE;
EXCEPTION
WHEN OTHERS THEN
  RAISE;
END;
$$;
 K   DROP FUNCTION public."resetPwd"(userid integer, newpwd character varying);
       public          postgres    false    5            R           1255    18443 �   save_alert(character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying)    FUNCTION     9  CREATE FUNCTION public.save_alert(auid character varying, vimei character varying, vno character varying, atype character varying, vlon character varying, vlat character varying, rptdate character varying, ghash character varying, spd character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
DECLARE
  alert_id integer;
  alert_date timestamp;

BEGIN
  alert_id:=0;
  alert_date:=to_timestamp(rptdate,'ddMMyy HH24miss');
  --select count(*) into alert_cnt from alert_log where rpt_date::date=alert_date::date AND alert_type=atype;
  UPDATE alert_log SET alert_uid=auid,imei=vimei,veh_no=vno,alert_type=atype,
	 lon=vlon,lat=vlat,rpt_date=alert_date,geohash=ghash,speed=spd
	 where rpt_date::date=alert_date::date AND alert_type=atype AND imei=vimei;
  	 GET DIAGNOSTICS alert_id = ROW_COUNT;
  
  IF alert_id=0 THEN
     INSERT INTO alert_log(alert_uid,imei,veh_no,alert_type,lon,lat,rpt_date,geohash,speed)
	 VALUES (auid,vimei,vno,atype,vlon,vlat,alert_date::timestamp,ghash,spd);
  END IF;
  return TRUE;
  
EXCEPTION
WHEN OTHERS THEN
  RAISE;
  return FALSE;
END;
$$;
 �   DROP FUNCTION public.save_alert(auid character varying, vimei character varying, vno character varying, atype character varying, vlon character varying, vlat character varying, rptdate character varying, ghash character varying, spd character varying);
       public          postgres    false    5            \           1255    18444    savefencegft(json)    FUNCTION     E  CREATE FUNCTION public.savefencegft(fencedata json) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
DECLARE
  i json;
  
BEGIN
  FOR i IN SELECT * FROM json_each(fenceData) LOOP
  	RAISE NOTICE 'VALUE OF i:(%) ',i;
    RAISE NOTICE 'VALUE OF data:(%) ',fenceData;
    -- RAISE NOTICE 'VALUE (%)',fenceData#>>'{i,"fenceName"}';
    -- RAISE NOTICE 'VALUE (%)',fenceData#>'{i,"fenceName"}';
    --RAISE NOTICE 'VALUE new  (%)',fencedata->cast(i as text)->'fenceName';
  	INSERT INTO fence_gft(fencename, lat, lng, radius,distance) VALUES (fencedata->cast(i as text)->'fenceName',fencedata->cast(i as text)->'lat',fencedata->cast(i as text)->'lng',fencedata->cast(i as text)->'radius',fencedata->cast(i as text)->'distFrom1st');
  END LOOP;
  return 'TRUE';

EXCEPTION WHEN OTHERS THEN
   
  	RAISE ;
  	return 'FALSE';

  	
      
END;
$$;
 3   DROP FUNCTION public.savefencegft(fencedata json);
       public          postgres    false    5            d           1255    18445    savefencegft(json, integer)    FUNCTION     �  CREATE FUNCTION public.savefencegft(fencedata json, routeid integer) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
DECLARE
  i json;
  j integer;
  fenceId integer;
  fenceArr integer[];
  counts integer :=1;
BEGIN
  FOR i IN SELECT * FROM json_array_elements(fenceData) LOOP
  	RAISE NOTICE 'VALUE OF i:(%) ',i;
    RAISE NOTICE 'VALUE OF data:(%) ',fenceData;
    -- RAISE NOTICE 'VALUE (%)',fenceData#>>'{i,"fenceName"}';
    -- RAISE NOTICE 'VALUE (%)',fenceData#>'{i,"fenceName"}';
    --RAISE NOTICE 'VALUE new  (%)',fencedata->cast(i as text)->'fenceName';
  	INSERT INTO fence_gft(fencename, data, lat, lng, radius,distance) VALUES (i->>'fenceName',ST_buffer(ST_geomFromText(i->>'geoText'),(i->>'radius')::integer/110000,'quad_segs=8')::geography,i->>'lat',i->>'lng',i->>'radius',i->>'distFrom1st') returning gft_id into fenceId;
 	fenceArr[counts]:=fenceId;
	counts=counts+1;
 END LOOP;
 	RAISE NOTICE 'VALUE array  (%)',fenceArr;
    
    FOR j IN 1..array_upper(fenceArr,1) LOOP
    	RAISE NOTICE 'VALUE OF j:(%) ',j;
  		INSERT INTO route_fences(route_id, fenceid_gft) VALUES(routeid,fenceArr[j]);
  	END LOOP;
    
  return 'TRUE';

EXCEPTION WHEN OTHERS THEN
   
  	RAISE ;
  	return 'FALSE';

  	
      
END;
$$;
 D   DROP FUNCTION public.savefencegft(fencedata json, routeid integer);
       public          postgres    false    5            M           1255    22997    searchimei(integer)    FUNCTION     �   CREATE FUNCTION public.searchimei(srh_imei integer) RETURNS TABLE(id integer, imei character varying)
    LANGUAGE plpgsql
    AS $$
    BEGIN
	RETURN QUERY
	SELECT id, imei FROM device_details WHERE imei LIKE srh_imei;
    END;
$$;
 3   DROP FUNCTION public.searchimei(srh_imei integer);
       public          postgres    false    5            e           1255    18446 (   sendstockresp(integer, integer, integer)    FUNCTION     (  CREATE FUNCTION public.sendstockresp(groupingrange integer, dealeruserid integer, requestid integer) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
DECLARE
  idGroup integer[];
  imeiGroup bigint[];
  startt integer;
  endd integer;
  availableCount integer;
  arrayId json;
  respType varchar := 'confirmed';
  i json;
  j json;
  countInt integer :=0;
BEGIN
 	SELECT count(*),array_agg(dd.id),array_agg(dd.imei) into availableCount,idGroup,imeiGroup FROM (SELECT * FRom device_details WHERE status='NEW' order by id ASC LIMIT groupingrange) as dd; 
    RAISE NOTICE 'result: (%)',idGroup;
    RAISE NOTICE 'available count: (%)',availableCount;
    
    startt:=idGroup[1];
    endd:=idGroup[array_upper(idGroup, 1)];
   
    RAISE NOTICE 'start: (%)',startt;
     RAISE NOTICE 'end: (%)',endd;
     
     INSERT INTO device_block(start, stop, count,dealer_userid,details)
     VALUES (startt,endd,availableCount,dealeruserid,imeiGroup);
     
     UPDATE device_details SET status='SUPPLIED' WHERE status='NEW' AND id between startt and endd;
     
     UPDATE request_notification SET status=respType,response=imeiGroup WHERE id=requestId;
     
    FOR j IN 1..array_upper(idGroup,1) LOOP
    	RAISE NOTICE 'VALUE OF j:(%) ',j;
  		INSERT INTO dealer_device(dealer_userid, device_id)
         VALUES (dealeruserid,idGroup[j]);
  	END LOOP;
     
    -- SELECT max(x) into endd FROM unnest(ARRAY[arrayId]) as x;
   -- SELECT idGroup[array_upper(idGroup, 1)] into start;
   --  RAISE NOTICE 'start: (%)',start;
    RETURN TRUE;
EXCEPTION WHEN OTHERS THEN
  RAISE;
END;
$$;
 d   DROP FUNCTION public.sendstockresp(groupingrange integer, dealeruserid integer, requestid integer);
       public          postgres    false    5            f           1255    18447    stockrequest(json, integer)    FUNCTION     ,  CREATE FUNCTION public.stockrequest(formdata json, userid integer) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
DECLARE
  id integer;
  i json;
  
BEGIN
  FOR i IN SELECT * FROM json_array_elements(formData) LOOP
  INSERT INTO request_notification(req_type, from_role, to_role, from_id, details, remarks, seen,status,product) VALUES('stock request','Dealer','Admin',userId,i->>'numOfReq',i->>'remarks',false,'Not Delivered',i->>'typeOfReq');
  END LOOP;
  return 'TRUE';

EXCEPTION WHEN OTHERS THEN
   
  	RAISE ;
  	return 'FALSE';

  	
      
END;
$$;
 B   DROP FUNCTION public.stockrequest(formdata json, userid integer);
       public          postgres    false    5            g           1255    18448 $   stockrequest(json, integer, integer)    FUNCTION     L  CREATE FUNCTION public.stockrequest(formdata json, userid integer, addedby integer) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
DECLARE
  id integer;
  i json;
  
BEGIN
  FOR i IN SELECT * FROM json_array_elements(formData) LOOP
  INSERT INTO request_notification(req_type, from_role, to_role, from_id, details, remarks, seen,status,product, to_id) VALUES('stock request','Dealer','Admin',userId,i->>'numOfReq',i->>'remarks',false,'Not Delivered',i->>'typeOfReq',addedby);
  END LOOP;
  return 'TRUE';

EXCEPTION WHEN OTHERS THEN
   
  	RAISE ;
  	return 'FALSE';

  	
      
END;
$$;
 S   DROP FUNCTION public.stockrequest(formdata json, userid integer, addedby integer);
       public          postgres    false    5            h           1255    18449    stockrequestbycp(json, integer)    FUNCTION     ,  CREATE FUNCTION public.stockrequestbycp(formdata json, userid integer) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
DECLARE
  id integer;
  i json;
  
BEGIN
  FOR i IN SELECT * FROM json_array_elements(formData) LOOP
  INSERT INTO request_notification(req_type, from_role, to_role, from_id, details, remarks, seen,status,product) VALUES('stock request','CP','Admin',userId,i->>'numOfReq',i->>'remarks',false,'Not Delivered',i->>'typeOfReq');
  END LOOP;
  return 'TRUE';

EXCEPTION WHEN OTHERS THEN
   
  	RAISE ;
  	return 'FALSE';

  	
      
END;
$$;
 F   DROP FUNCTION public.stockrequestbycp(formdata json, userid integer);
       public          postgres    false    5            i           1255    18450    stockresponse(integer)    FUNCTION     N  CREATE FUNCTION public.stockresponse(intgrprange integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
cmf1 record;
cnt INTEGER;
allData JSON;
arrayIds INTEGER[];
rec_deviceId record;
start integer;
endN integer;
countInt integer :=0;
cur_devideIds1 CURSOR FOR SELECT id::integer FROM device_details WHERE status='NEW' ORDER BY id ASC LIMIT intgrprange;
BEGIN
   --	CREATE TEMP TABLE table_holder AS SELECT id::integer FROM device_details WHERE status='NEW' ORDER BY id ASC LIMIT intgrprange;
	--SELECT count(*)::integer INTO cnt FROM device_details WHERE status='NEW' LIMIT intgrprange;
   	SELECT COUNT(*)::integer INTO cnt FROM (SELECT * FROM device_details WHERE status='NEW' LIMIT intgrprange) AS a;
    IF cnt=intgrprange THEN
    	--RETURN cnt;
        OPEN cur_devideIds1;
        --FOR id IN 1..cnt LOOP 
        --FOR id IN cur_devideIds1 LOOP
        LOOP	
        	FETCH cur_devideIds1 INTO rec_deviceId;
            countInt=countInt+1;
            
           -- IF countInt=1 THEN
            	--start:=id;
         --  END IF;
           RAISE NOTICE 'The current value of counter is %', countInt;
           --EXIT WHEN NOT FOUND;
            
        	IF countInt=1 THEN
            	FETCH cur_devideIds1 INTO start;
            ELSEIF countInt=cnt THEN
            	FETCH cur_devideIds1 INTO endN;
            END IF;
            
        	--FETCH cur_devideIds INTO rec_deviceId;
            EXIT WHEN NOT FOUND;
        END LOOP;
        CLOSE cur_devideIds1;
    END IF;
    --FOR id IN cmf1 LOOP
    	
   -- END LOOP;
    RETURN start;
EXCEPTION WHEN OTHERS THEN
  RAISE;
END;
$$;
 9   DROP FUNCTION public.stockresponse(intgrprange integer);
       public          postgres    false    5            j           1255    18451    stockresponse2(integer)    FUNCTION       CREATE FUNCTION public.stockresponse2(intgrprange integer) RETURNS TABLE(cmf1 integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
   	return query SELECT id::integer as cmf1 FROM device_details WHERE status='NEW' ORDER BY id ASC LIMIT intgrprange;
EXCEPTION WHEN OTHERS THEN
  RAISE;
END;
$$;
 :   DROP FUNCTION public.stockresponse2(intgrprange integer);
       public          postgres    false    5            �            1259    18452    device_details    TABLE     �  CREATE TABLE public.device_details (
    id integer NOT NULL,
    imei character varying(20) NOT NULL,
    serial_number character varying,
    manufact_date date,
    manufacturer character varying,
    status character varying,
    sim_no character varying,
    sim_no2 character varying,
    manuf_id integer,
    iccid character varying(30),
    restart_cnt integer,
    last_restart_date timestamp(0) without time zone,
    dev_type character varying(3),
    hw_license_id integer,
    sw_license_id integer,
    sw_licenseid character varying,
    sim_no_validt date,
    sim_no2_validt date,
    m2m_provider character varying(30)
);
 "   DROP TABLE public.device_details;
       public         heap    postgres    false    5            k           1255    18457    stockresponsenew(integer)    FUNCTION     �  CREATE FUNCTION public.stockresponsenew(intgrprange integer) RETURNS SETOF public.device_details
    LANGUAGE plpgsql
    AS $$
BEGIN
   	return query SELECT * FROM device_details WHERE status='NEW' ORDER BY id ASC LIMIT intgrprange;
	--return query SELECT id || '::integer as cmf1' FROM device_details WHERE status='NEW' ORDER BY id ASC LIMIT intgrprange;
EXCEPTION WHEN OTHERS THEN
  RAISE;
END;
$$;
 <   DROP FUNCTION public.stockresponsenew(intgrprange integer);
       public          postgres    false    215    5            l           1255    18458 (   stockresptocp(integer, integer, integer)    FUNCTION     	  CREATE FUNCTION public.stockresptocp(groupingrange integer, cpuserid integer, requestid integer) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
DECLARE
  idGroup integer[];
  imeiGroup bigint[];
  startt integer;
  endd integer;
  availableCount integer;
  arrayId json;
  respType varchar := 'confirmed';
  i json;
  j json;
  countInt integer :=0;
BEGIN
 	SELECT count(*),array_agg(dd.id),array_agg(dd.imei) into availableCount,idGroup,imeiGroup FROM (SELECT * FRom device_details WHERE status='NEW' order by id ASC LIMIT groupingrange) as dd; 
    RAISE NOTICE 'result: (%)',idGroup;
    RAISE NOTICE 'available count: (%)',availableCount;
    
    startt:=idGroup[1];
    endd:=idGroup[array_upper(idGroup, 1)];
   
    RAISE NOTICE 'start: (%)',startt;
    RAISE NOTICE 'end: (%)',endd;
     
    INSERT INTO device_block(start, stop, count,dealer_userid,details)
    VALUES (startt,endd,availableCount,cpuserid,imeiGroup);
     
    UPDATE device_details SET status='CP' WHERE status='NEW' AND id between startt and endd;
     
    UPDATE request_notification SET status=respType,response=imeiGroup WHERE id=requestId;
     
    FOR j IN 1..array_upper(idGroup,1) LOOP
    	RAISE NOTICE 'VALUE OF j:(%) ',j;
  		INSERT INTO cp_device(cp_userid, device_id)
         VALUES (cpuserid,idGroup[j]);
  	END LOOP;
     
    -- SELECT max(x) into endd FROM unnest(ARRAY[arrayId]) as x;
   -- SELECT idGroup[array_upper(idGroup, 1)] into start;
   --  RAISE NOTICE 'start: (%)',start;
    RETURN TRUE;
EXCEPTION WHEN OTHERS THEN
  RAISE;
END;
$$;
 `   DROP FUNCTION public.stockresptocp(groupingrange integer, cpuserid integer, requestid integer);
       public          postgres    false    5            m           1255    18459 7   stockresptodlrfrmcp(integer, integer, integer, integer)    FUNCTION     �  CREATE FUNCTION public.stockresptodlrfrmcp(groupingrange integer, cpuserid integer, dealeruserid integer, requestid integer) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
DECLARE
  idGroup integer[];
  imeiGroup bigint[];
  startt integer;
  endd integer;
  availableCount integer;
  arrayId json;
  respType varchar := 'confirmed';
  i json;
  j json;
  countInt integer :=0;
BEGIN
 	SELECT count(*),array_agg(dd.id),array_agg(dd.imei) into availableCount,idGroup,imeiGroup FROM (SELECT d.id,d.imei from device_details d inner join cp_device cpd on cpd.device_id=d.id  WHERE d.status='CP' AND cpd.cp_userid=cpuserid order by d.id ASC LIMIT groupingrange) as dd;  
    RAISE NOTICE 'result: (%)',idGroup;
    RAISE NOTICE 'available count: (%)',availableCount;
    
    startt:=idGroup[1];
    endd:=idGroup[array_upper(idGroup, 1)];
   
    RAISE NOTICE 'start: (%)',startt;
     RAISE NOTICE 'end: (%)',endd;
     
     INSERT INTO device_block(start, stop, count,dealer_userid,details)
     VALUES (startt,endd,availableCount,dealeruserid,imeiGroup);
     
     UPDATE device_details SET status='SUPPLIED' WHERE status='CP' AND id between startt and endd;
     
     UPDATE request_notification SET status=respType,response=imeiGroup WHERE id=requestId;
     
    FOR j IN 1..array_upper(idGroup,1) LOOP
    	RAISE NOTICE 'VALUE OF j:(%) ',j;
  		INSERT INTO dealer_device(dealer_userid, device_id)
         VALUES (dealeruserid,idGroup[j]);
  	END LOOP;
     
    -- SELECT max(x) into endd FROM unnest(ARRAY[arrayId]) as x;
   -- SELECT idGroup[array_upper(idGroup, 1)] into start;
   --  RAISE NOTICE 'start: (%)',start;
    RETURN TRUE;
EXCEPTION WHEN OTHERS THEN
  RAISE;
END;
$$;
 |   DROP FUNCTION public.stockresptodlrfrmcp(groupingrange integer, cpuserid integer, dealeruserid integer, requestid integer);
       public          postgres    false    5            n           1255    18460    stocktocp(integer, integer)    FUNCTION     �  CREATE FUNCTION public.stocktocp(groupingrange integer, cpuserid integer) RETURNS bigint[]
    LANGUAGE plpgsql
    AS $$
DECLARE
  idGroup integer[];
  imeiGroup bigint[];
  startt integer;
  endd integer;
  availableCount integer;
  j json;
BEGIN

	SELECT count(*),array_agg(dd.id),array_agg(dd.imei) into availableCount,idGroup,imeiGroup FROM (SELECT * FRom device_details WHERE status='NEW' order by id ASC LIMIT groupingrange) as dd; 
    RAISE NOTICE 'result: (%)',idGroup;
    RAISE NOTICE 'available count: (%)',availableCount;
    RAISE NOTICE 'Required qty: (%)',groupingrange;
    
    IF groupingrange=availableCount THEN
    	
        startt:=idGroup[1];
        endd:=idGroup[array_upper(idGroup, 1)];
         
        RAISE NOTICE 'start: (%)',startt;
        RAISE NOTICE 'end: (%)',endd;
           
        UPDATE device_details SET status='CP' WHERE status='NEW' AND id between startt and endd;
           
        FOR j IN 1..array_upper(idGroup,1) LOOP
            RAISE NOTICE 'VALUE OF j:(%) ',j;
            INSERT INTO cp_device(cp_userid, device_id)
             VALUES (cpuserid,idGroup[j]);
        END LOOP;     
   		RETURN imeiGroup;
      END IF;
	  RETURN null;
EXCEPTION
WHEN OTHERS THEN
  RAISE;
END;
$$;
 I   DROP FUNCTION public.stocktocp(groupingrange integer, cpuserid integer);
       public          postgres    false    5            o           1255    18461 �   update_dealer(character varying, character varying, character varying, character varying, character varying, character varying, integer, character varying, character varying, integer, character varying, character varying)    FUNCTION     �  CREATE FUNCTION public.update_dealer(vname character varying, vemail character varying, vpwd character varying, vmob character varying, vaddr character varying, vact character varying, vuid integer, vcname character varying, vgstno character varying, vcid integer, vstate character varying, vdistrict character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$BEGIN

UPDATE  userinfo SET name=vname, email=vemail, pwd=vpwd ,mobile=vmob ,address=vaddr,active=vact WHERE id=vuid;
UPDATE dealer SET  company_name=vcname, active=(CASE WHEN vact='t' THEN TRUE ELSE FALSE END), gst_no=vgstno ,district=vdistrict,state=vstate WHERE id=vcid;
RETURN TRUE;
EXCEPTION WHEN OTHERS THEN
  RAISE;
END;$$;
 ?  DROP FUNCTION public.update_dealer(vname character varying, vemail character varying, vpwd character varying, vmob character varying, vaddr character varying, vact character varying, vuid integer, vcname character varying, vgstno character varying, vcid integer, vstate character varying, vdistrict character varying);
       public          postgres    false    5            p           1255    18462 �   update_distrib(character varying, character varying, character varying, character varying, character varying, character varying, integer, character varying, character varying, integer)    FUNCTION     E  CREATE FUNCTION public.update_distrib(vname character varying, vemail character varying, vpwd character varying, vmob character varying, vaddr character varying, vact character varying, vuid integer, vcname character varying, vgstno character varying, vcid integer) RETURNS boolean
    LANGUAGE plpgsql
    AS $$BEGIN

UPDATE  userinfo SET name=vname, email=vemail, pwd=vpwd ,
mobile=vmob ,address=vaddr,active=vact WHERE id=vuid;
UPDATE channel_partner SET  company_name=vcname, 
active=vact, gst_no=vgstno  WHERE id=vcid;
RETURN TRUE;
EXCEPTION
WHEN OTHERS THEN
  RAISE;
END;$$;
 	  DROP FUNCTION public.update_distrib(vname character varying, vemail character varying, vpwd character varying, vmob character varying, vaddr character varying, vact character varying, vuid integer, vcname character varying, vgstno character varying, vcid integer);
       public          postgres    false    5            q           1255    18463 G   update_user_details(json, integer, integer, integer, character varying)    FUNCTION     �  CREATE FUNCTION public.update_user_details(data json, manufid integer, distrid integer, franid integer, hpwd character varying) RETURNS json
    LANGUAGE plpgsql
    AS $$
DECLARE
uid integer;
uname varchar;
umob varchar;

BEGIN

uid:=(data->>'edt_own_id')::integer;
uname:=(data->>'edt_own_name');
umob:=(data->>'edt_own_mob');

IF (SELECT count(*) from userinfo where id!=uid and
	manuf_id=manufid and distr_id=distrid and 
	franc_id =franid and (name=uname or mobile=umob))>0 THEN
		RETURN '{"message":"User with entered Name or Mobile No already exist."}';
ELSE
	 UPDATE userinfo set name=uname,email=data->>'edt_own_mail',pwd=hpwd,mobile=umob,
	 address=data->>'edt_own_addr' where id=uid and manuf_id=manufid and 
	 distr_id=distrid and franc_id =franid;
	 UPDATE mob_vehicle_map SET mobno=umob where owner_id=uid;
		
	 RETURN '{"message":"User details Updated."}';

END IF;

EXCEPTION

WHEN OTHERS THEN
RAISE;

END;
$$;
    DROP FUNCTION public.update_user_details(data json, manufid integer, distrid integer, franid integer, hpwd character varying);
       public          postgres    false    5            r           1255    18464    update_veh_detals(json)    FUNCTION       CREATE FUNCTION public.update_veh_detals(data json) RETURNS json
    LANGUAGE plpgsql
    AS $$DECLARE
vehno varchar;
imeino varchar;
vehnocnt integer;
devcnt integer;
edt_veh_id integer;
user_id integer;
edt_own_id integer;
BEGIN
edt_veh_id:=(data->>'edt_veh_id')::integer;
edt_own_id:=(data->>'edt_own_id')::integer;
SELECT veh_no,imei into vehno,imeino  FROM veh_info where veh_id=edt_veh_id;
SELECT userid INTO user_id from user_veh where vehid=edt_veh_id;
IF vehno=data->>'edt_vehRegno' THEN --Vehicle No is same
    IF imeino=data->>'edt_imeiDis' THEN -- Vehicle No & Imei are same
		UPDATE device_details set sim_no=data->>'edt_simno1',sim_no2=data->>'edt_simno2' where imei=imeino;
		UPDATE veh_info set veh_type=data->>'edt_vehtype' where veh_id=edt_veh_id;
		IF user_id!=edt_own_id THEN --Owner Changed (Vehicle No & Imei are same)
		   UPDATE user_veh SET userid=edt_own_id WHERE vehid=edt_veh_id;
		   UPDATE subscription_details set user_id=edt_own_id,sub_period=(data->>'edt_subs_prd')::integer where entity_id=imeino;
		   UPDATE mob_vehicle_map SET mobno=data->>'edt_own_mob',owner_id=edt_own_id where veh_no=vehno;
		ELSE
			UPDATE subscription_details set sub_period=(data->>'edt_subs_prd')::integer where entity_id=imeino;
		END IF;
		
		RETURN '{"message":"Vehicle Details Updated Successfully "}';
	ELSE --Imei changed but vehno same
		IF (SELECT count(*) FROM veh_info where imei=data->>'edt_imeiDis' AND veh_id!=edt_veh_id)>0 THEN
			   RETURN '{"message":"Entered Imei already tagged to another vehicle."}';
		ELSE
				UPDATE veh_info set imei=data->>'edt_imeiDis',veh_type=data->>'edt_vehtype' where veh_id=edt_veh_id;
				IF user_id!=edt_own_id THEN --Owner Changed (Imei changed but vehno same)
				   UPDATE user_veh SET userid=edt_own_id WHERE vehid=edt_veh_id;
				   UPDATE subscription_details set user_id=edt_own_id,entity_id=data->>'edt_imeiDis',sub_period=(data->>'edt_subs_prd')::integer where entity_id=imeino;
				   UPDATE mob_vehicle_map SET mobno=data->>'edt_own_mob',owner_id=edt_own_id,imei=data->>'edt_imeiDis' where veh_no=vehno;
				ELSE
					UPDATE subscription_details set entity_id=data->>'edt_imeiDis',sub_period=(data->>'edt_subs_prd')::integer where entity_id=imeino;
					UPDATE mob_vehicle_map SET imei=data->>'edt_imeiDis' where veh_no=vehno;
				END IF;
				
				select count(*) into devcnt from device_details where imei=data->>'edt_imeiDis';
				IF devcnt=0 then 
				 INSERT INTO device_details(imei,sim_no,sim_no2) VALUES(data->>'edt_imeiDis',data->>'edt_simno1',data->>'edt_simno2');
				ELSE
				 UPDATE device_details SET sim_no=data->>'edt_simno1',sim_no2=data->>'edt_simno2' where imei=data->>'edt_imeiDis';
				END IF;
				 
				RETURN '{"message":"Vehicle Details Updated Successfully "}';
	   END IF;
	END IF;
ELSE--Vehicle No changed
    IF (SELECT count(*) FROM veh_info where veh_no=data->>'edt_vehRegno')>0 THEN
		   RETURN '{"message":"Entered Vehicle No already tagged to another device"}';
	ELSE
	    IF imeino=data->>'edt_imeiDis' THEN -- Vehicle No Changed but Imei is same
			UPDATE veh_info set veh_no=data->>'edt_vehRegno',veh_type=data->>'edt_vehtype' where veh_id=edt_veh_id;
			IF user_id!=edt_own_id THEN --Owner Changed (Vehicle No Changed but Imei is same)
			   UPDATE user_veh SET userid=edt_own_id WHERE vehid=edt_veh_id;
			   UPDATE subscription_details set user_id=edt_own_id,sub_period=(data->>'edt_subs_prd')::integer where entity_id=imeino;
			   UPDATE mob_vehicle_map SET mobno=data->>'edt_own_mob',owner_id=edt_own_id,veh_no=data->>'edt_vehRegno' where veh_no=vehno;
			ELSE
				UPDATE subscription_details set user_id=edt_own_id,sub_period=(data->>'edt_subs_prd')::integer where entity_id=imeino;
				UPDATE mob_vehicle_map SET veh_no=data->>'edt_vehRegno' where veh_no=vehno;
			END IF;
			RETURN '{"message":"Vehicle Details Updated Successfully "}';
			
		ELSE --Imei & Vehicle No changed
			IF (SELECT count(*) FROM veh_info where imei=data->>'edt_imeiDis' AND veh_id!=edt_veh_id)>0 THEN
			   RETURN '{"message":"Entered Imei already tagged to another vehicle "}';
			ELSE
				UPDATE veh_info set veh_no=data->>'edt_vehRegno',imei=data->>'edt_imeiDis',veh_type=data->>'edt_vehtype' where veh_id=edt_veh_id;
				IF user_id!=edt_own_id THEN --Owner Changed (Imei & Vehicle No changed)
				   UPDATE user_veh SET userid=edt_own_id WHERE vehid=edt_veh_id;
				   UPDATE subscription_details set user_id=edt_own_id,entity_id=data->>'edt_imeiDis',sub_period=(data->>'edt_subs_prd')::integer where entity_id=imeino;
				   UPDATE mob_vehicle_map SET mobno=data->>'edt_own_mob',owner_id=edt_own_id,veh_no=data->>'edt_vehRegno',imei=data->>'edt_imeiDis' where veh_no=vehno;
				ELSE
					UPDATE subscription_details set entity_id=data->>'edt_imeiDis',sub_period=(data->>'edt_subs_prd')::integer where entity_id=imeino;
					UPDATE mob_vehicle_map SET veh_no=data->>'edt_vehRegno',imei=data->>'edt_imeiDis' where veh_no=vehno;
				END IF;
				
				select count(*) into devcnt from device_details where imei=data->>'edt_imeiDis';
				IF devcnt=0 then 
				 INSERT INTO device_details(imei,sim_no,sim_no2) VALUES(data->>'edt_imeiDis',data->>'edt_simno1',data->>'edt_simno2');
				ELSE
				 UPDATE device_details SET sim_no=data->>'edt_simno1',sim_no2=data->>'edt_simno2' where imei=data->>'edt_imeiDis';
				END IF;
				RETURN '{"message":"Vehicle Details Updated Successfully "}';
			END IF;
		END IF;
	END IF;
END IF;

EXCEPTION
WHEN OTHERS THEN
  RAISE;
 return '{"message":"Error Saving Record"}';
END;
$$;
 3   DROP FUNCTION public.update_veh_detals(data json);
       public          postgres    false    5            �            1259    18465    account_mobile_map    TABLE     �   CREATE TABLE public.account_mobile_map (
    account_id integer NOT NULL,
    plan_id integer,
    app_id character varying NOT NULL,
    mobno character varying(15) NOT NULL,
    id integer NOT NULL
);
 &   DROP TABLE public.account_mobile_map;
       public         heap    postgres    false    5            �            1259    18470    account_mobile_map_id_seq    SEQUENCE     �   CREATE SEQUENCE public.account_mobile_map_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 0   DROP SEQUENCE public.account_mobile_map_id_seq;
       public          postgres    false    5    216            j           0    0    account_mobile_map_id_seq    SEQUENCE OWNED BY     W   ALTER SEQUENCE public.account_mobile_map_id_seq OWNED BY public.account_mobile_map.id;
          public          postgres    false    217            �            1259    18471    alert    TABLE     �   CREATE TABLE public.alert (
    id bigint NOT NULL,
    geoid bigint NOT NULL,
    vehid bigint,
    seen boolean,
    userid bigint,
    stat character varying,
    "time" character varying
);
    DROP TABLE public.alert;
       public         heap    postgres    false    5            �            1259    18476    alert_id_seq    SEQUENCE     u   CREATE SEQUENCE public.alert_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 #   DROP SEQUENCE public.alert_id_seq;
       public          postgres    false    5    218            k           0    0    alert_id_seq    SEQUENCE OWNED BY     =   ALTER SEQUENCE public.alert_id_seq OWNED BY public.alert.id;
          public          postgres    false    219            �            1259    18477    alert_log_id_seq    SEQUENCE     y   CREATE SEQUENCE public.alert_log_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 '   DROP SEQUENCE public.alert_log_id_seq;
       public          postgres    false    5            �            1259    18478 	   alert_log    TABLE     X  CREATE TABLE public.alert_log (
    id integer DEFAULT nextval('public.alert_log_id_seq'::regclass) NOT NULL,
    alert_uid character varying(29),
    imei character varying(15) NOT NULL,
    veh_no character varying(15),
    alert_type character varying(5),
    lon character varying(12),
    lat character varying(12),
    status character varying(6),
    rpt_src character varying(6),
    rpt_date timestamp without time zone,
    device_status character varying(5),
    geohash character varying(12),
    remarks character varying(50),
    speed character varying,
    gf_id character varying
);
    DROP TABLE public.alert_log;
       public         heap    postgres    false    220    5            �            1259    18484    alert_settings    TABLE     O  CREATE TABLE public.alert_settings (
    id integer NOT NULL,
    alrtname character varying NOT NULL,
    alrttype character varying NOT NULL,
    active boolean NOT NULL,
    pushurl character varying,
    fleet json NOT NULL,
    details json NOT NULL,
    sendto json NOT NULL,
    createdby character varying,
    rds_raw json
);
 "   DROP TABLE public.alert_settings;
       public         heap    postgres    false    5            �            1259    18489    alert_settings_id_seq    SEQUENCE     �   CREATE SEQUENCE public.alert_settings_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 ,   DROP SEQUENCE public.alert_settings_id_seq;
       public          postgres    false    222    5            l           0    0    alert_settings_id_seq    SEQUENCE OWNED BY     O   ALTER SEQUENCE public.alert_settings_id_seq OWNED BY public.alert_settings.id;
          public          postgres    false    223            �            1259    18490    app_routing_table    TABLE     �   CREATE TABLE public.app_routing_table (
    app_base_url character varying(200) NOT NULL,
    destination character varying(200)
);
 %   DROP TABLE public.app_routing_table;
       public         heap    postgres    false    5            �            1259    18493    channel_partner_id_seq    SEQUENCE        CREATE SEQUENCE public.channel_partner_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 -   DROP SEQUENCE public.channel_partner_id_seq;
       public          postgres    false    5            �            1259    18494    channel_partner    TABLE     �  CREATE TABLE public.channel_partner (
    id integer DEFAULT nextval('public.channel_partner_id_seq'::regclass) NOT NULL,
    user_id integer NOT NULL,
    added_by integer NOT NULL,
    secmob character varying,
    gst_no character varying(25),
    company_name character varying(30),
    active character varying(1),
    logo character varying,
    state integer,
    district integer
);
 #   DROP TABLE public.channel_partner;
       public         heap    postgres    false    225    5            �            1259    18500    count    TABLE     0   CREATE TABLE public.count (
    count bigint
);
    DROP TABLE public.count;
       public         heap    postgres    false    5            �            1259    18503 	   cp_device    TABLE     {   CREATE TABLE public.cp_device (
    id integer NOT NULL,
    cp_userid integer NOT NULL,
    device_id integer NOT NULL
);
    DROP TABLE public.cp_device;
       public         heap    postgres    false    5            �            1259    18506    cp_device_id_seq    SEQUENCE     �   CREATE SEQUENCE public.cp_device_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 '   DROP SEQUENCE public.cp_device_id_seq;
       public          postgres    false    228    5            m           0    0    cp_device_id_seq    SEQUENCE OWNED BY     E   ALTER SEQUENCE public.cp_device_id_seq OWNED BY public.cp_device.id;
          public          postgres    false    229            �            1259    18507    crew    TABLE     �   CREATE TABLE public.crew (
    c_id integer NOT NULL,
    name character varying NOT NULL,
    emp_type character varying NOT NULL,
    kyc_details json NOT NULL,
    createdby bigint NOT NULL,
    mob character varying
);
    DROP TABLE public.crew;
       public         heap    postgres    false    5            �            1259    18512    crew_c_id_seq    SEQUENCE     �   CREATE SEQUENCE public.crew_c_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 $   DROP SEQUENCE public.crew_c_id_seq;
       public          postgres    false    5    230            n           0    0    crew_c_id_seq    SEQUENCE OWNED BY     ?   ALTER SEQUENCE public.crew_c_id_seq OWNED BY public.crew.c_id;
          public          postgres    false    231            �            1259    18513    crew_veh    TABLE     v   CREATE TABLE public.crew_veh (
    cid integer NOT NULL,
    crew_id integer NOT NULL,
    veh_id integer NOT NULL
);
    DROP TABLE public.crew_veh;
       public         heap    postgres    false    5            �            1259    18516    crew_veh_cid_seq    SEQUENCE     �   CREATE SEQUENCE public.crew_veh_cid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 '   DROP SEQUENCE public.crew_veh_cid_seq;
       public          postgres    false    5    232            o           0    0    crew_veh_cid_seq    SEQUENCE OWNED BY     E   ALTER SEQUENCE public.crew_veh_cid_seq OWNED BY public.crew_veh.cid;
          public          postgres    false    233            �            1259    18517    dealer    TABLE     �  CREATE TABLE public.dealer (
    id integer NOT NULL,
    dealer_name character varying,
    phone_num character varying(13),
    sec_phn_num character varying(13),
    mail character varying,
    address character varying,
    user_id integer,
    company_name character varying,
    logo_filename character varying,
    active boolean,
    added_by integer,
    gst_no character varying(50),
    district character varying(50),
    state character varying(50)
);
    DROP TABLE public.dealer;
       public         heap    postgres    false    5            �            1259    18522    dealer_device    TABLE     p   CREATE TABLE public.dealer_device (
    id integer NOT NULL,
    dealer_userid integer,
    device_id bigint
);
 !   DROP TABLE public.dealer_device;
       public         heap    postgres    false    5            �            1259    18525    dealer_device_id_seq    SEQUENCE     �   CREATE SEQUENCE public.dealer_device_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 +   DROP SEQUENCE public.dealer_device_id_seq;
       public          postgres    false    235    5            p           0    0    dealer_device_id_seq    SEQUENCE OWNED BY     M   ALTER SEQUENCE public.dealer_device_id_seq OWNED BY public.dealer_device.id;
          public          postgres    false    236            �            1259    18526    dealer_id_seq    SEQUENCE     �   CREATE SEQUENCE public.dealer_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 $   DROP SEQUENCE public.dealer_id_seq;
       public          postgres    false    234    5            q           0    0    dealer_id_seq    SEQUENCE OWNED BY     ?   ALTER SEQUENCE public.dealer_id_seq OWNED BY public.dealer.id;
          public          postgres    false    237            �            1259    18527    dev_otp    TABLE     �   CREATE TABLE public.dev_otp (
    id bigint NOT NULL,
    imei character varying NOT NULL,
    otphash character varying NOT NULL,
    date date DEFAULT now()
);
    DROP TABLE public.dev_otp;
       public         heap    postgres    false    5            �            1259    18533    dev_otp_id_seq    SEQUENCE     w   CREATE SEQUENCE public.dev_otp_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 %   DROP SEQUENCE public.dev_otp_id_seq;
       public          postgres    false    238    5            r           0    0    dev_otp_id_seq    SEQUENCE OWNED BY     A   ALTER SEQUENCE public.dev_otp_id_seq OWNED BY public.dev_otp.id;
          public          postgres    false    239            C           1259    22984    devcnt    TABLE     1   CREATE TABLE public.devcnt (
    count bigint
);
    DROP TABLE public.devcnt;
       public         heap    postgres    false    5            �            1259    18534    device_block    TABLE     �   CREATE TABLE public.device_block (
    id integer NOT NULL,
    start integer NOT NULL,
    stop integer NOT NULL,
    count integer,
    dealer_userid integer,
    details character varying
);
     DROP TABLE public.device_block;
       public         heap    postgres    false    5            �            1259    18539    device_block_id_seq    SEQUENCE     �   CREATE SEQUENCE public.device_block_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 *   DROP SEQUENCE public.device_block_id_seq;
       public          postgres    false    5    240            s           0    0    device_block_id_seq    SEQUENCE OWNED BY     K   ALTER SEQUENCE public.device_block_id_seq OWNED BY public.device_block.id;
          public          postgres    false    241            �            1259    18540    device_details_id_seq    SEQUENCE     �   CREATE SEQUENCE public.device_details_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 ,   DROP SEQUENCE public.device_details_id_seq;
       public          postgres    false    215    5            t           0    0    device_details_id_seq    SEQUENCE OWNED BY     O   ALTER SEQUENCE public.device_details_id_seq OWNED BY public.device_details.id;
          public          postgres    false    242            �            1259    18541    subscription_details    TABLE     �  CREATE TABLE public.subscription_details (
    sub_id integer NOT NULL,
    user_id integer,
    entity_id character varying(20),
    metering_type character varying,
    start_date date,
    end_date date,
    status character varying,
    entity_type character varying,
    phonenumber character varying,
    kyc_id character varying,
    kyc_type character varying,
    name character varying,
    manuf_id integer,
    distr_id integer,
    franc_id integer,
    sub_period integer
);
 (   DROP TABLE public.subscription_details;
       public         heap    postgres    false    5            �            1259    18546    user_veh    TABLE     H   CREATE TABLE public.user_veh (
    userid integer,
    vehid integer
);
    DROP TABLE public.user_veh;
       public         heap    postgres    false    5            �            1259    18549    userinfo    TABLE     V  CREATE TABLE public.userinfo (
    id bigint NOT NULL,
    name character varying(40) NOT NULL,
    email character varying(120) NOT NULL,
    pwd character varying NOT NULL,
    mobile character varying(15) NOT NULL,
    image_url character varying DEFAULT 'images/no-img.png'::character varying,
    sec_mob character varying(15),
    address character varying(300) NOT NULL,
    tenentid character varying(30),
    addedby bigint NOT NULL,
    active character varying,
    manuf_id bigint,
    distr_id bigint,
    franc_id bigint,
    user_type character(2),
    app_id integer DEFAULT 101
);
    DROP TABLE public.userinfo;
       public         heap    postgres    false    5            �            1259    18556    veh_info    TABLE     �  CREATE TABLE public.veh_info (
    veh_id integer NOT NULL,
    veh_no character varying,
    imei character varying(20),
    veh_type character varying,
    veh_category character varying,
    veh_class character varying,
    "Veh_group" character varying,
    colour character varying,
    "Veh_make" character varying,
    model character varying,
    "Manfc_year" integer,
    "Veh_name" character varying,
    dev_manuf_id integer,
    dev_distr_id integer,
    dev_franc_id integer
);
    DROP TABLE public.veh_info;
       public         heap    postgres    false    5            �            1259    18561    device_list_master    VIEW     ]  CREATE VIEW public.device_list_master AS
 SELECT v.veh_id,
    v.veh_no,
    v.imei,
    v.dev_manuf_id,
    v.dev_distr_id,
    v.dev_franc_id,
    u.id AS owner_id,
    u.name AS ownername,
    u.mobile,
    u.active,
    sd.end_date,
    v.veh_type,
    sd.sub_period,
    sd.start_date,
    dd.iccid,
    dd.serial_number,
    dd.sim_no,
    dd.sim_no2,
    cp.company_name AS distrib,
    de.company_name AS dealer
   FROM ((((((public.veh_info v
     JOIN public.user_veh uv ON ((v.veh_id = uv.vehid)))
     JOIN public.device_details dd ON (((dd.imei)::text = (v.imei)::text)))
     JOIN public.userinfo u ON ((uv.userid = u.id)))
     JOIN public.channel_partner cp ON ((cp.user_id = v.dev_distr_id)))
     JOIN public.dealer de ON ((de.user_id = v.dev_franc_id)))
     JOIN public.subscription_details sd ON (((sd.entity_id)::text = (v.imei)::text)));
 %   DROP VIEW public.device_list_master;
       public          postgres    false    215    226    234    244    246    246    215    215    246    243    246    246    243    215    234    215    226    243    246    246    245    245    243    245    245    244    5            �            1259    18566 	   districts    TABLE     �  CREATE TABLE public.districts (
    district_id integer NOT NULL,
    district_name character varying(50) NOT NULL,
    state_id integer NOT NULL,
    active boolean DEFAULT true NOT NULL
);
ALTER TABLE ONLY public.districts ALTER COLUMN district_id SET STATISTICS 0;
ALTER TABLE ONLY public.districts ALTER COLUMN district_name SET STATISTICS 0;
ALTER TABLE ONLY public.districts ALTER COLUMN state_id SET STATISTICS 0;
ALTER TABLE ONLY public.districts ALTER COLUMN active SET STATISTICS 0;
    DROP TABLE public.districts;
       public         heap    postgres    false    5            �            1259    18570    districts_district_id_seq    SEQUENCE     �   CREATE SEQUENCE public.districts_district_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 0   DROP SEQUENCE public.districts_district_id_seq;
       public          postgres    false    5    248            u           0    0    districts_district_id_seq    SEQUENCE OWNED BY     W   ALTER SEQUENCE public.districts_district_id_seq OWNED BY public.districts.district_id;
          public          postgres    false    249            �            1259    18571    fence_gft_gft_id_seq    SEQUENCE     �   CREATE SEQUENCE public.fence_gft_gft_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 +   DROP SEQUENCE public.fence_gft_gft_id_seq;
       public          postgres    false    5            �            1259    18572    fence_id_seq    SEQUENCE     u   CREATE SEQUENCE public.fence_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 #   DROP SEQUENCE public.fence_id_seq;
       public          postgres    false    5            �            1259    18573    imei_board_serial    TABLE     |   CREATE TABLE public.imei_board_serial (
    imei numeric(15,0) NOT NULL,
    board_serial character varying(30) NOT NULL
);
 %   DROP TABLE public.imei_board_serial;
       public         heap    postgres    false    5            �            1259    18576    lc_data    TABLE     �  CREATE TABLE public.lc_data (
    lc_id integer NOT NULL,
    h3 character varying(10),
    h4 character varying(10),
    h5 character varying(10),
    h6 character varying(10),
    lat numeric,
    lon numeric,
    rg_loc_name character varying,
    md_loc_name character varying,
    dist character varying(30),
    state character varying(30),
    cntry character varying(30),
    dt_status character(3),
    active boolean
);
    DROP TABLE public.lc_data;
       public         heap    postgres    false    5            �            1259    18581    lc_data_1_lc_id_seq    SEQUENCE     �   CREATE SEQUENCE public.lc_data_1_lc_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 *   DROP SEQUENCE public.lc_data_1_lc_id_seq;
       public          postgres    false    253    5            v           0    0    lc_data_1_lc_id_seq    SEQUENCE OWNED BY     I   ALTER SEQUENCE public.lc_data_1_lc_id_seq OWNED BY public.lc_data.lc_id;
          public          postgres    false    254            �            1259    18582    lc_data_lc_id_seq    SEQUENCE     z   CREATE SEQUENCE public.lc_data_lc_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 (   DROP SEQUENCE public.lc_data_lc_id_seq;
       public          postgres    false    5                        1259    18583    lc_data_old    TABLE     �  CREATE TABLE public.lc_data_old (
    lc_id integer DEFAULT nextval('public.lc_data_lc_id_seq'::regclass) NOT NULL,
    h3 character varying(10),
    h4 character varying(10),
    h5 character varying(10),
    h6 character varying(10),
    lat numeric,
    lon numeric,
    rg_loc_name character varying,
    md_loc_name character varying,
    dist character varying(30),
    state character varying(30),
    cntry character varying(30),
    dt_status character(3),
    active boolean
);
    DROP TABLE public.lc_data_old;
       public         heap    postgres    false    255    5                       1259    18589 
   logincount    TABLE     J   CREATE TABLE public.logincount (
    userid integer,
    count integer
);
    DROP TABLE public.logincount;
       public         heap    postgres    false    5                       1259    18592    menus    TABLE     u  CREATE TABLE public.menus (
    id integer NOT NULL,
    menu_name character varying NOT NULL,
    menu_url character varying,
    parent_menu integer,
    hassubmenu integer,
    layer integer,
    created_by bigint NOT NULL,
    icon character varying DEFAULT 'fa-id-card-o'::character varying NOT NULL,
    view character varying NOT NULL,
    type character varying
);
    DROP TABLE public.menus;
       public         heap    postgres    false    5                       1259    18598    menus_id_seq    SEQUENCE     �   CREATE SEQUENCE public.menus_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 #   DROP SEQUENCE public.menus_id_seq;
       public          postgres    false    5    258            w           0    0    menus_id_seq    SEQUENCE OWNED BY     =   ALTER SEQUENCE public.menus_id_seq OWNED BY public.menus.id;
          public          postgres    false    259                       1259    18599    mob_plan_details    TABLE     �   CREATE TABLE public.mob_plan_details (
    planid integer NOT NULL,
    plantype character varying,
    planname character varying NOT NULL
);
 $   DROP TABLE public.mob_plan_details;
       public         heap    postgres    false    5                       1259    18604    mob_plan_details_planid_seq    SEQUENCE     �   CREATE SEQUENCE public.mob_plan_details_planid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 2   DROP SEQUENCE public.mob_plan_details_planid_seq;
       public          postgres    false    260    5            x           0    0    mob_plan_details_planid_seq    SEQUENCE OWNED BY     [   ALTER SEQUENCE public.mob_plan_details_planid_seq OWNED BY public.mob_plan_details.planid;
          public          postgres    false    261                       1259    18605    mob_plan_menu_map    TABLE     �   CREATE TABLE public.mob_plan_menu_map (
    plan_id integer NOT NULL,
    menu_type character varying,
    menu_id integer NOT NULL,
    id integer NOT NULL
);
 %   DROP TABLE public.mob_plan_menu_map;
       public         heap    postgres    false    5                       1259    18610    mob_plan_menu_map_id_seq    SEQUENCE     �   CREATE SEQUENCE public.mob_plan_menu_map_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 /   DROP SEQUENCE public.mob_plan_menu_map_id_seq;
       public          postgres    false    262    5            y           0    0    mob_plan_menu_map_id_seq    SEQUENCE OWNED BY     U   ALTER SEQUENCE public.mob_plan_menu_map_id_seq OWNED BY public.mob_plan_menu_map.id;
          public          postgres    false    263                       1259    18611    mob_vehicle_map    TABLE     �  CREATE TABLE public.mob_vehicle_map (
    appid character varying DEFAULT 101,
    mobno character varying(14) NOT NULL,
    veh_no character varying(20),
    veh_name character varying,
    imei character varying(20) NOT NULL,
    owner_id integer NOT NULL,
    owner_type character varying,
    acc_type character varying,
    acc_id integer,
    exp_date date NOT NULL,
    id integer NOT NULL,
    plan_id integer DEFAULT 1
);
 #   DROP TABLE public.mob_vehicle_map;
       public         heap    postgres    false    5            	           1259    18618    mob_vehicle_map_id_seq    SEQUENCE     �   CREATE SEQUENCE public.mob_vehicle_map_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 -   DROP SEQUENCE public.mob_vehicle_map_id_seq;
       public          postgres    false    264    5            z           0    0    mob_vehicle_map_id_seq    SEQUENCE OWNED BY     Q   ALTER SEQUENCE public.mob_vehicle_map_id_seq OWNED BY public.mob_vehicle_map.id;
          public          postgres    false    265            
           1259    18619    notifications_id_seq    SEQUENCE     }   CREATE SEQUENCE public.notifications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 +   DROP SEQUENCE public.notifications_id_seq;
       public          postgres    false    5                       1259    18620    product_master    TABLE     �   CREATE TABLE public.product_master (
    product character varying(3) NOT NULL,
    pcb character varying(2) NOT NULL,
    ems character varying(2) NOT NULL,
    slno numeric NOT NULL,
    batch numeric NOT NULL
);
 "   DROP TABLE public.product_master;
       public         heap    postgres    false    5                       1259    18625    pwd_reset_log    TABLE     �   CREATE TABLE public.pwd_reset_log (
    id integer NOT NULL,
    userid bigint NOT NULL,
    req_count integer NOT NULL,
    date date DEFAULT now(),
    urlhash character varying NOT NULL,
    otp character varying
);
 !   DROP TABLE public.pwd_reset_log;
       public         heap    postgres    false    5                       1259    18631    pwd_reset_log_id_seq    SEQUENCE     �   CREATE SEQUENCE public.pwd_reset_log_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 +   DROP SEQUENCE public.pwd_reset_log_id_seq;
       public          postgres    false    5    268            {           0    0    pwd_reset_log_id_seq    SEQUENCE OWNED BY     M   ALTER SEQUENCE public.pwd_reset_log_id_seq OWNED BY public.pwd_reset_log.id;
          public          postgres    false    269                       1259    18632    report    TABLE     	  CREATE TABLE public.report (
    id bigint NOT NULL,
    imei character varying NOT NULL,
    userid bigint NOT NULL,
    lats character varying NOT NULL,
    date date NOT NULL,
    "time" time(6) without time zone NOT NULL,
    lngs character varying NOT NULL
);
    DROP TABLE public.report;
       public         heap    postgres    false    5                       1259    18637    report_id_seq    SEQUENCE     v   CREATE SEQUENCE public.report_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 $   DROP SEQUENCE public.report_id_seq;
       public          postgres    false    5    270            |           0    0    report_id_seq    SEQUENCE OWNED BY     ?   ALTER SEQUENCE public.report_id_seq OWNED BY public.report.id;
          public          postgres    false    271                       1259    18638    request_notification    TABLE     �  CREATE TABLE public.request_notification (
    id integer DEFAULT nextval('public.notifications_id_seq'::regclass) NOT NULL,
    req_type character varying NOT NULL,
    from_role character varying NOT NULL,
    to_role character varying NOT NULL,
    from_id integer NOT NULL,
    details character varying NOT NULL,
    remarks character varying,
    seen boolean NOT NULL,
    status character varying,
    response character varying,
    product character varying,
    to_id integer
);
 (   DROP TABLE public.request_notification;
       public         heap    postgres    false    266    5                       1259    18644 	   role_menu    TABLE     �   CREATE TABLE public.role_menu (
    role_id integer NOT NULL,
    menu_id integer NOT NULL,
    menu_order integer,
    id integer NOT NULL
);
    DROP TABLE public.role_menu;
       public         heap    postgres    false    5                       1259    18647    role_menu_id_seq    SEQUENCE     �   CREATE SEQUENCE public.role_menu_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 '   DROP SEQUENCE public.role_menu_id_seq;
       public          postgres    false    5    273            }           0    0    role_menu_id_seq    SEQUENCE OWNED BY     E   ALTER SEQUENCE public.role_menu_id_seq OWNED BY public.role_menu.id;
          public          postgres    false    274                       1259    18648    roles    TABLE       CREATE TABLE public.roles (
    id integer NOT NULL,
    role_name character varying NOT NULL,
    active character varying(1) NOT NULL,
    icon_class character varying NOT NULL,
    plan_based character varying(1) NOT NULL,
    addedby integer NOT NULL
);
    DROP TABLE public.roles;
       public         heap    postgres    false    5                       1259    18653    roles_id_seq    SEQUENCE     �   CREATE SEQUENCE public.roles_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 #   DROP SEQUENCE public.roles_id_seq;
       public          postgres    false    5    275            ~           0    0    roles_id_seq    SEQUENCE OWNED BY     =   ALTER SEQUENCE public.roles_id_seq OWNED BY public.roles.id;
          public          postgres    false    276                       1259    18654    route_fence    TABLE     �   CREATE TABLE public.route_fence (
    route_fence_id integer NOT NULL,
    route_id integer NOT NULL,
    fence_data json NOT NULL
);
    DROP TABLE public.route_fence;
       public         heap    postgres    false    5                       1259    18659    route_fences    TABLE     �   CREATE TABLE public.route_fences (
    route_fences_id integer NOT NULL,
    route_id integer NOT NULL,
    fenceid_gft integer NOT NULL
);
     DROP TABLE public.route_fences;
       public         heap    postgres    false    5                       1259    18662     route_fences_route_fences_id_seq    SEQUENCE     �   CREATE SEQUENCE public.route_fences_route_fences_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 7   DROP SEQUENCE public.route_fences_route_fences_id_seq;
       public          postgres    false    5    278                       0    0     route_fences_route_fences_id_seq    SEQUENCE OWNED BY     e   ALTER SEQUENCE public.route_fences_route_fences_id_seq OWNED BY public.route_fences.route_fences_id;
          public          postgres    false    279                       1259    18663 
   route_trip    TABLE     �   CREATE TABLE public.route_trip (
    route_id integer NOT NULL,
    trip_id integer NOT NULL,
    route_trip_id integer NOT NULL
);
    DROP TABLE public.route_trip;
       public         heap    postgres    false    5                       1259    18666    route_trip_route_trip_id_seq    SEQUENCE     �   CREATE SEQUENCE public.route_trip_route_trip_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 3   DROP SEQUENCE public.route_trip_route_trip_id_seq;
       public          postgres    false    280    5            �           0    0    route_trip_route_trip_id_seq    SEQUENCE OWNED BY     ]   ALTER SEQUENCE public.route_trip_route_trip_id_seq OWNED BY public.route_trip.route_trip_id;
          public          postgres    false    281                       1259    18667    sim_data    TABLE     �   CREATE TABLE public.sim_data (
    iccid1 character varying NOT NULL,
    msisdn1 character varying NOT NULL,
    imsi1 character varying NOT NULL,
    iccid2 character varying,
    imsi2 character varying,
    msisdn2 character varying NOT NULL
);
    DROP TABLE public.sim_data;
       public         heap    postgres    false    5                       1259    18672    states    TABLE     �   CREATE TABLE public.states (
    state_id integer NOT NULL,
    state_name character varying(50) NOT NULL,
    active boolean DEFAULT true NOT NULL
);
    DROP TABLE public.states;
       public         heap    postgres    false    5                       1259    18676    states_state_id_seq    SEQUENCE     �   CREATE SEQUENCE public.states_state_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 *   DROP SEQUENCE public.states_state_id_seq;
       public          postgres    false    283    5            �           0    0    states_state_id_seq    SEQUENCE OWNED BY     K   ALTER SEQUENCE public.states_state_id_seq OWNED BY public.states.state_id;
          public          postgres    false    284                       1259    18677    subscription_details_sub_id_seq    SEQUENCE     �   CREATE SEQUENCE public.subscription_details_sub_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 6   DROP SEQUENCE public.subscription_details_sub_id_seq;
       public          postgres    false    5    243            �           0    0    subscription_details_sub_id_seq    SEQUENCE OWNED BY     c   ALTER SEQUENCE public.subscription_details_sub_id_seq OWNED BY public.subscription_details.sub_id;
          public          postgres    false    285            E           1259    22999    subscription_history    TABLE       CREATE TABLE public.subscription_history (
    id bigint NOT NULL,
    sub_id integer NOT NULL,
    user_id integer NOT NULL,
    entity_id character varying,
    start_date date,
    end_date date,
    status character varying,
    phonenumber character varying,
    kyc_id character varying,
    kyc_type character varying,
    name character varying,
    manuf_id integer,
    distr_id integer,
    franc_id integer,
    sub_period integer,
    metering_type character varying,
    entity_type character varying,
    entry_date date
);
 (   DROP TABLE public.subscription_history;
       public         heap    postgres    false    5            D           1259    22998    subscription_history_id_seq    SEQUENCE     �   CREATE SEQUENCE public.subscription_history_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 2   DROP SEQUENCE public.subscription_history_id_seq;
       public          postgres    false    5    325            �           0    0    subscription_history_id_seq    SEQUENCE OWNED BY     [   ALTER SEQUENCE public.subscription_history_id_seq OWNED BY public.subscription_history.id;
          public          postgres    false    324                       1259    18678    testmake    TABLE     _   CREATE TABLE public.testmake (
    id integer NOT NULL,
    make character varying NOT NULL
);
    DROP TABLE public.testmake;
       public         heap    postgres    false    5                       1259    18683    testmake_id_seq    SEQUENCE     �   CREATE SEQUENCE public.testmake_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 &   DROP SEQUENCE public.testmake_id_seq;
       public          postgres    false    286    5            �           0    0    testmake_id_seq    SEQUENCE OWNED BY     C   ALTER SEQUENCE public.testmake_id_seq OWNED BY public.testmake.id;
          public          postgres    false    287                        1259    18684 	   testmodel    TABLE        CREATE TABLE public.testmodel (
    id integer NOT NULL,
    make_id integer NOT NULL,
    model character varying NOT NULL
);
    DROP TABLE public.testmodel;
       public         heap    postgres    false    5            !           1259    18689    testmodel_id_seq    SEQUENCE     �   CREATE SEQUENCE public.testmodel_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 '   DROP SEQUENCE public.testmodel_id_seq;
       public          postgres    false    288    5            �           0    0    testmodel_id_seq    SEQUENCE OWNED BY     E   ALTER SEQUENCE public.testmodel_id_seq OWNED BY public.testmodel.id;
          public          postgres    false    289            "           1259    18690    trip    TABLE     �   CREATE TABLE public.trip (
    tripid integer NOT NULL,
    fence json,
    type character varying,
    triplabel character varying,
    details json
);
    DROP TABLE public.trip;
       public         heap    postgres    false    5            #           1259    18695 
   trip_fence    TABLE     v   CREATE TABLE public.trip_fence (
    trip_fence_id integer NOT NULL,
    trip_id integer,
    fence_id_gft integer
);
    DROP TABLE public.trip_fence;
       public         heap    postgres    false    5            $           1259    18698    trip_fence_trip_fence_id_seq    SEQUENCE     �   CREATE SEQUENCE public.trip_fence_trip_fence_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 3   DROP SEQUENCE public.trip_fence_trip_fence_id_seq;
       public          postgres    false    5    291            �           0    0    trip_fence_trip_fence_id_seq    SEQUENCE OWNED BY     ]   ALTER SEQUENCE public.trip_fence_trip_fence_id_seq OWNED BY public.trip_fence.trip_fence_id;
          public          postgres    false    292            %           1259    18699    trip_tripid_seq    SEQUENCE     �   CREATE SEQUENCE public.trip_tripid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 &   DROP SEQUENCE public.trip_tripid_seq;
       public          postgres    false    5    290            �           0    0    trip_tripid_seq    SEQUENCE OWNED BY     C   ALTER SEQUENCE public.trip_tripid_seq OWNED BY public.trip.tripid;
          public          postgres    false    293            &           1259    18700    tripschedule    TABLE     �   CREATE TABLE public.tripschedule (
    id integer NOT NULL,
    vehid integer,
    data character varying,
    type character varying,
    mode character varying
);
     DROP TABLE public.tripschedule;
       public         heap    postgres    false    5            '           1259    18705    tripschedule_id_seq    SEQUENCE     �   CREATE SEQUENCE public.tripschedule_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 *   DROP SEQUENCE public.tripschedule_id_seq;
       public          postgres    false    5    294            �           0    0    tripschedule_id_seq    SEQUENCE OWNED BY     K   ALTER SEQUENCE public.tripschedule_id_seq OWNED BY public.tripschedule.id;
          public          postgres    false    295            (           1259    18706    url_mapping    TABLE     L  CREATE TABLE public.url_mapping (
    url_key character varying(100) NOT NULL,
    host character varying(200),
    token_location character varying(10),
    token_field_name character varying(100),
    token_value character varying(2048),
    url_chop_portion character varying(200),
    map_type character varying(20) NOT NULL
);
    DROP TABLE public.url_mapping;
       public         heap    postgres    false    5            )           1259    18711    user_edit_otp    TABLE     �   CREATE TABLE public.user_edit_otp (
    id integer NOT NULL,
    user_id integer,
    date timestamp(6) with time zone,
    otphash character varying,
    status character varying(10)
);
 !   DROP TABLE public.user_edit_otp;
       public         heap    postgres    false    5            *           1259    18716    user_edit_otp_id_seq    SEQUENCE     �   CREATE SEQUENCE public.user_edit_otp_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 +   DROP SEQUENCE public.user_edit_otp_id_seq;
       public          postgres    false    5    297            �           0    0    user_edit_otp_id_seq    SEQUENCE OWNED BY     M   ALTER SEQUENCE public.user_edit_otp_id_seq OWNED BY public.user_edit_otp.id;
          public          postgres    false    298            +           1259    18717 
   user_fence    TABLE     o   CREATE TABLE public.user_fence (
    userid integer,
    fenceid integer,
    usr_fence_id integer NOT NULL
);
    DROP TABLE public.user_fence;
       public         heap    postgres    false    5            ,           1259    18720    user_fence_usr_fence_id_seq    SEQUENCE     �   CREATE SEQUENCE public.user_fence_usr_fence_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 2   DROP SEQUENCE public.user_fence_usr_fence_id_seq;
       public          postgres    false    5    299            �           0    0    user_fence_usr_fence_id_seq    SEQUENCE OWNED BY     [   ALTER SEQUENCE public.user_fence_usr_fence_id_seq OWNED BY public.user_fence.usr_fence_id;
          public          postgres    false    300            -           1259    18721 
   user_roles    TABLE     �   CREATE TABLE public.user_roles (
    user_id bigint NOT NULL,
    role_id integer NOT NULL,
    active character varying(1) NOT NULL,
    default_role character varying(1),
    addedby bigint NOT NULL,
    id integer NOT NULL
);
    DROP TABLE public.user_roles;
       public         heap    postgres    false    5            .           1259    18724    user_roles_id_seq    SEQUENCE     �   CREATE SEQUENCE public.user_roles_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 (   DROP SEQUENCE public.user_roles_id_seq;
       public          postgres    false    5    301            �           0    0    user_roles_id_seq    SEQUENCE OWNED BY     G   ALTER SEQUENCE public.user_roles_id_seq OWNED BY public.user_roles.id;
          public          postgres    false    302            /           1259    18725    user_routing    TABLE     �   CREATE TABLE public.user_routing (
    id integer NOT NULL,
    uid bigint NOT NULL,
    host character varying(60) NOT NULL
);
     DROP TABLE public.user_routing;
       public         heap    postgres    false    5            0           1259    18728    user_routing_id_seq    SEQUENCE     �   CREATE SEQUENCE public.user_routing_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 *   DROP SEQUENCE public.user_routing_id_seq;
       public          postgres    false    303    5            �           0    0    user_routing_id_seq    SEQUENCE OWNED BY     K   ALTER SEQUENCE public.user_routing_id_seq OWNED BY public.user_routing.id;
          public          postgres    false    304            1           1259    18729    user_vehicle_master    VIEW     �  CREATE VIEW public.user_vehicle_master AS
 SELECT v.veh_id,
    v.veh_no,
    v.imei,
    v.dev_manuf_id,
    v.dev_distr_id,
    v.dev_franc_id,
    u.id,
    u.name,
    u.mobile,
    u.manuf_id,
    u.distr_id,
    u.franc_id,
    u.active,
    sd.end_date,
    v.veh_type,
    sd.sub_period,
    sd.start_date,
    dd.sim_no,
    dd.sim_no2
   FROM ((((public.veh_info v
     JOIN public.user_veh uv ON ((v.veh_id = uv.vehid)))
     JOIN public.userinfo u ON ((uv.userid = u.id)))
     JOIN public.subscription_details sd ON (((sd.entity_id)::text = (v.imei)::text)))
     LEFT JOIN public.device_details dd ON (((dd.imei)::text = (v.imei)::text)));
 &   DROP VIEW public.user_vehicle_master;
       public          postgres    false    246    246    246    215    215    246    245    245    215    245    245    243    243    246    246    246    245    245    245    244    244    243    243    5            2           1259    18734    userinfo_id_seq    SEQUENCE     x   CREATE SEQUENCE public.userinfo_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 &   DROP SEQUENCE public.userinfo_id_seq;
       public          postgres    false    245    5            �           0    0    userinfo_id_seq    SEQUENCE OWNED BY     C   ALTER SEQUENCE public.userinfo_id_seq OWNED BY public.userinfo.id;
          public          postgres    false    306            3           1259    18735 	   usertheme    TABLE     �   CREATE TABLE public.usertheme (
    id integer NOT NULL,
    userid integer,
    header character varying,
    sidebar character varying
);
    DROP TABLE public.usertheme;
       public         heap    postgres    false    5            4           1259    18740    usertheme_id_seq    SEQUENCE     �   CREATE SEQUENCE public.usertheme_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 '   DROP SEQUENCE public.usertheme_id_seq;
       public          postgres    false    5    307            �           0    0    usertheme_id_seq    SEQUENCE OWNED BY     E   ALTER SEQUENCE public.usertheme_id_seq OWNED BY public.usertheme.id;
          public          postgres    false    308            5           1259    18741    veh_details    TABLE     �   CREATE TABLE public.veh_details (
    veh_id integer NOT NULL,
    type character varying,
    amount character varying,
    start_date date,
    end_date date,
    number character varying,
    id integer NOT NULL
);
    DROP TABLE public.veh_details;
       public         heap    postgres    false    5            6           1259    18746    veh_details_id_seq    SEQUENCE     �   CREATE SEQUENCE public.veh_details_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 )   DROP SEQUENCE public.veh_details_id_seq;
       public          postgres    false    309    5            �           0    0    veh_details_id_seq    SEQUENCE OWNED BY     I   ALTER SEQUENCE public.veh_details_id_seq OWNED BY public.veh_details.id;
          public          postgres    false    310            7           1259    18747    veh_deviceinfo_veh_id_seq    SEQUENCE     �   CREATE SEQUENCE public.veh_deviceinfo_veh_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 0   DROP SEQUENCE public.veh_deviceinfo_veh_id_seq;
       public          postgres    false    246    5            �           0    0    veh_deviceinfo_veh_id_seq    SEQUENCE OWNED BY     Q   ALTER SEQUENCE public.veh_deviceinfo_veh_id_seq OWNED BY public.veh_info.veh_id;
          public          postgres    false    311            8           1259    18748 	   veh_fence    TABLE     �   CREATE TABLE public.veh_fence (
    id integer NOT NULL,
    vehid integer,
    fenceid integer,
    type character varying,
    details json,
    "time" time without time zone
);
    DROP TABLE public.veh_fence;
       public         heap    postgres    false    5            9           1259    18753    veh_fence_id_seq    SEQUENCE     �   CREATE SEQUENCE public.veh_fence_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 '   DROP SEQUENCE public.veh_fence_id_seq;
       public          postgres    false    5    312            �           0    0    veh_fence_id_seq    SEQUENCE OWNED BY     E   ALTER SEQUENCE public.veh_fence_id_seq OWNED BY public.veh_fence.id;
          public          postgres    false    313            :           1259    18754    veh_make    TABLE     c   CREATE TABLE public.veh_make (
    makeid integer NOT NULL,
    make character varying NOT NULL
);
    DROP TABLE public.veh_make;
       public         heap    postgres    false    5            ;           1259    18759    veh_make_makeid_seq    SEQUENCE     �   CREATE SEQUENCE public.veh_make_makeid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 *   DROP SEQUENCE public.veh_make_makeid_seq;
       public          postgres    false    5    314            �           0    0    veh_make_makeid_seq    SEQUENCE OWNED BY     K   ALTER SEQUENCE public.veh_make_makeid_seq OWNED BY public.veh_make.makeid;
          public          postgres    false    315            <           1259    18760 	   veh_model    TABLE        CREATE TABLE public.veh_model (
    id integer NOT NULL,
    make_id integer NOT NULL,
    model character varying NOT NULL
);
    DROP TABLE public.veh_model;
       public         heap    postgres    false    5            =           1259    18765    veh_model_id_seq    SEQUENCE     �   CREATE SEQUENCE public.veh_model_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 '   DROP SEQUENCE public.veh_model_id_seq;
       public          postgres    false    5    316            �           0    0    veh_model_id_seq    SEQUENCE OWNED BY     E   ALTER SEQUENCE public.veh_model_id_seq OWNED BY public.veh_model.id;
          public          postgres    false    317            >           1259    18766    veh_trip    TABLE     l   CREATE TABLE public.veh_trip (
    veh_trip_id integer NOT NULL,
    veh_id integer,
    trip_id integer
);
    DROP TABLE public.veh_trip;
       public         heap    postgres    false    5            ?           1259    18769    veh_trip_veh_trip_id_seq    SEQUENCE     �   CREATE SEQUENCE public.veh_trip_veh_trip_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 /   DROP SEQUENCE public.veh_trip_veh_trip_id_seq;
       public          postgres    false    318    5            �           0    0    veh_trip_veh_trip_id_seq    SEQUENCE OWNED BY     U   ALTER SEQUENCE public.veh_trip_veh_trip_id_seq OWNED BY public.veh_trip.veh_trip_id;
          public          postgres    false    319            @           1259    18770    vlt_details    TABLE     �   CREATE TABLE public.vlt_details (
    imei numeric NOT NULL,
    iccid character varying(50) NOT NULL,
    sl_no character varying(20)
);
    DROP TABLE public.vlt_details;
       public         heap    postgres    false    5            A           1259    18775 
   vts_routes    TABLE     �   CREATE TABLE public.vts_routes (
    routeid integer NOT NULL,
    routename character varying,
    createdby integer,
    createddate date,
    totaldistance character varying,
    routelabel character varying
);
    DROP TABLE public.vts_routes;
       public         heap    postgres    false    5            B           1259    18780    vts_routes_routeid_seq    SEQUENCE     �   CREATE SEQUENCE public.vts_routes_routeid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 -   DROP SEQUENCE public.vts_routes_routeid_seq;
       public          postgres    false    5    321            �           0    0    vts_routes_routeid_seq    SEQUENCE OWNED BY     Q   ALTER SEQUENCE public.vts_routes_routeid_seq OWNED BY public.vts_routes.routeid;
          public          postgres    false    322            �           2604    18781    account_mobile_map id    DEFAULT     ~   ALTER TABLE ONLY public.account_mobile_map ALTER COLUMN id SET DEFAULT nextval('public.account_mobile_map_id_seq'::regclass);
 D   ALTER TABLE public.account_mobile_map ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    217    216            �           2604    18782    alert id    DEFAULT     d   ALTER TABLE ONLY public.alert ALTER COLUMN id SET DEFAULT nextval('public.alert_id_seq'::regclass);
 7   ALTER TABLE public.alert ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    219    218            �           2604    18783    alert_settings id    DEFAULT     v   ALTER TABLE ONLY public.alert_settings ALTER COLUMN id SET DEFAULT nextval('public.alert_settings_id_seq'::regclass);
 @   ALTER TABLE public.alert_settings ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    223    222            �           2604    18784    cp_device id    DEFAULT     l   ALTER TABLE ONLY public.cp_device ALTER COLUMN id SET DEFAULT nextval('public.cp_device_id_seq'::regclass);
 ;   ALTER TABLE public.cp_device ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    229    228            �           2604    18785 	   crew c_id    DEFAULT     f   ALTER TABLE ONLY public.crew ALTER COLUMN c_id SET DEFAULT nextval('public.crew_c_id_seq'::regclass);
 8   ALTER TABLE public.crew ALTER COLUMN c_id DROP DEFAULT;
       public          postgres    false    231    230            �           2604    18786    crew_veh cid    DEFAULT     l   ALTER TABLE ONLY public.crew_veh ALTER COLUMN cid SET DEFAULT nextval('public.crew_veh_cid_seq'::regclass);
 ;   ALTER TABLE public.crew_veh ALTER COLUMN cid DROP DEFAULT;
       public          postgres    false    233    232            �           2604    18787 	   dealer id    DEFAULT     f   ALTER TABLE ONLY public.dealer ALTER COLUMN id SET DEFAULT nextval('public.dealer_id_seq'::regclass);
 8   ALTER TABLE public.dealer ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    237    234            �           2604    18788    dealer_device id    DEFAULT     t   ALTER TABLE ONLY public.dealer_device ALTER COLUMN id SET DEFAULT nextval('public.dealer_device_id_seq'::regclass);
 ?   ALTER TABLE public.dealer_device ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    236    235            �           2604    18789 
   dev_otp id    DEFAULT     h   ALTER TABLE ONLY public.dev_otp ALTER COLUMN id SET DEFAULT nextval('public.dev_otp_id_seq'::regclass);
 9   ALTER TABLE public.dev_otp ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    239    238            �           2604    18790    device_block id    DEFAULT     r   ALTER TABLE ONLY public.device_block ALTER COLUMN id SET DEFAULT nextval('public.device_block_id_seq'::regclass);
 >   ALTER TABLE public.device_block ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    241    240            �           2604    18791    device_details id    DEFAULT     v   ALTER TABLE ONLY public.device_details ALTER COLUMN id SET DEFAULT nextval('public.device_details_id_seq'::regclass);
 @   ALTER TABLE public.device_details ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    242    215            �           2604    18792    districts district_id    DEFAULT     ~   ALTER TABLE ONLY public.districts ALTER COLUMN district_id SET DEFAULT nextval('public.districts_district_id_seq'::regclass);
 D   ALTER TABLE public.districts ALTER COLUMN district_id DROP DEFAULT;
       public          postgres    false    249    248            �           2604    18793    lc_data lc_id    DEFAULT     p   ALTER TABLE ONLY public.lc_data ALTER COLUMN lc_id SET DEFAULT nextval('public.lc_data_1_lc_id_seq'::regclass);
 <   ALTER TABLE public.lc_data ALTER COLUMN lc_id DROP DEFAULT;
       public          postgres    false    254    253            �           2604    18794    menus id    DEFAULT     d   ALTER TABLE ONLY public.menus ALTER COLUMN id SET DEFAULT nextval('public.menus_id_seq'::regclass);
 7   ALTER TABLE public.menus ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    259    258            �           2604    18795    mob_plan_details planid    DEFAULT     �   ALTER TABLE ONLY public.mob_plan_details ALTER COLUMN planid SET DEFAULT nextval('public.mob_plan_details_planid_seq'::regclass);
 F   ALTER TABLE public.mob_plan_details ALTER COLUMN planid DROP DEFAULT;
       public          postgres    false    261    260            �           2604    18796    mob_plan_menu_map id    DEFAULT     |   ALTER TABLE ONLY public.mob_plan_menu_map ALTER COLUMN id SET DEFAULT nextval('public.mob_plan_menu_map_id_seq'::regclass);
 C   ALTER TABLE public.mob_plan_menu_map ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    263    262            �           2604    18797    mob_vehicle_map id    DEFAULT     x   ALTER TABLE ONLY public.mob_vehicle_map ALTER COLUMN id SET DEFAULT nextval('public.mob_vehicle_map_id_seq'::regclass);
 A   ALTER TABLE public.mob_vehicle_map ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    265    264            �           2604    18798    pwd_reset_log id    DEFAULT     t   ALTER TABLE ONLY public.pwd_reset_log ALTER COLUMN id SET DEFAULT nextval('public.pwd_reset_log_id_seq'::regclass);
 ?   ALTER TABLE public.pwd_reset_log ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    269    268            �           2604    18799 	   report id    DEFAULT     f   ALTER TABLE ONLY public.report ALTER COLUMN id SET DEFAULT nextval('public.report_id_seq'::regclass);
 8   ALTER TABLE public.report ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    271    270            �           2604    18800    role_menu id    DEFAULT     l   ALTER TABLE ONLY public.role_menu ALTER COLUMN id SET DEFAULT nextval('public.role_menu_id_seq'::regclass);
 ;   ALTER TABLE public.role_menu ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    274    273            �           2604    18801    roles id    DEFAULT     d   ALTER TABLE ONLY public.roles ALTER COLUMN id SET DEFAULT nextval('public.roles_id_seq'::regclass);
 7   ALTER TABLE public.roles ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    276    275            �           2604    18802    route_fences route_fences_id    DEFAULT     �   ALTER TABLE ONLY public.route_fences ALTER COLUMN route_fences_id SET DEFAULT nextval('public.route_fences_route_fences_id_seq'::regclass);
 K   ALTER TABLE public.route_fences ALTER COLUMN route_fences_id DROP DEFAULT;
       public          postgres    false    279    278            �           2604    18803    route_trip route_trip_id    DEFAULT     �   ALTER TABLE ONLY public.route_trip ALTER COLUMN route_trip_id SET DEFAULT nextval('public.route_trip_route_trip_id_seq'::regclass);
 G   ALTER TABLE public.route_trip ALTER COLUMN route_trip_id DROP DEFAULT;
       public          postgres    false    281    280            �           2604    18804    states state_id    DEFAULT     r   ALTER TABLE ONLY public.states ALTER COLUMN state_id SET DEFAULT nextval('public.states_state_id_seq'::regclass);
 >   ALTER TABLE public.states ALTER COLUMN state_id DROP DEFAULT;
       public          postgres    false    284    283            �           2604    18805    subscription_details sub_id    DEFAULT     �   ALTER TABLE ONLY public.subscription_details ALTER COLUMN sub_id SET DEFAULT nextval('public.subscription_details_sub_id_seq'::regclass);
 J   ALTER TABLE public.subscription_details ALTER COLUMN sub_id DROP DEFAULT;
       public          postgres    false    285    243            �           2604    23002    subscription_history id    DEFAULT     �   ALTER TABLE ONLY public.subscription_history ALTER COLUMN id SET DEFAULT nextval('public.subscription_history_id_seq'::regclass);
 F   ALTER TABLE public.subscription_history ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    325    324    325            �           2604    18806    testmake id    DEFAULT     j   ALTER TABLE ONLY public.testmake ALTER COLUMN id SET DEFAULT nextval('public.testmake_id_seq'::regclass);
 :   ALTER TABLE public.testmake ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    287    286            �           2604    18807    testmodel id    DEFAULT     l   ALTER TABLE ONLY public.testmodel ALTER COLUMN id SET DEFAULT nextval('public.testmodel_id_seq'::regclass);
 ;   ALTER TABLE public.testmodel ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    289    288            �           2604    18808    trip tripid    DEFAULT     j   ALTER TABLE ONLY public.trip ALTER COLUMN tripid SET DEFAULT nextval('public.trip_tripid_seq'::regclass);
 :   ALTER TABLE public.trip ALTER COLUMN tripid DROP DEFAULT;
       public          postgres    false    293    290            �           2604    18809    trip_fence trip_fence_id    DEFAULT     �   ALTER TABLE ONLY public.trip_fence ALTER COLUMN trip_fence_id SET DEFAULT nextval('public.trip_fence_trip_fence_id_seq'::regclass);
 G   ALTER TABLE public.trip_fence ALTER COLUMN trip_fence_id DROP DEFAULT;
       public          postgres    false    292    291            �           2604    18810    tripschedule id    DEFAULT     r   ALTER TABLE ONLY public.tripschedule ALTER COLUMN id SET DEFAULT nextval('public.tripschedule_id_seq'::regclass);
 >   ALTER TABLE public.tripschedule ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    295    294            �           2604    18811    user_edit_otp id    DEFAULT     t   ALTER TABLE ONLY public.user_edit_otp ALTER COLUMN id SET DEFAULT nextval('public.user_edit_otp_id_seq'::regclass);
 ?   ALTER TABLE public.user_edit_otp ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    298    297            �           2604    18812    user_fence usr_fence_id    DEFAULT     �   ALTER TABLE ONLY public.user_fence ALTER COLUMN usr_fence_id SET DEFAULT nextval('public.user_fence_usr_fence_id_seq'::regclass);
 F   ALTER TABLE public.user_fence ALTER COLUMN usr_fence_id DROP DEFAULT;
       public          postgres    false    300    299            �           2604    18813    user_roles id    DEFAULT     n   ALTER TABLE ONLY public.user_roles ALTER COLUMN id SET DEFAULT nextval('public.user_roles_id_seq'::regclass);
 <   ALTER TABLE public.user_roles ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    302    301            �           2604    18814    user_routing id    DEFAULT     r   ALTER TABLE ONLY public.user_routing ALTER COLUMN id SET DEFAULT nextval('public.user_routing_id_seq'::regclass);
 >   ALTER TABLE public.user_routing ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    304    303            �           2604    18815    userinfo id    DEFAULT     j   ALTER TABLE ONLY public.userinfo ALTER COLUMN id SET DEFAULT nextval('public.userinfo_id_seq'::regclass);
 :   ALTER TABLE public.userinfo ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    306    245            �           2604    18816    usertheme id    DEFAULT     l   ALTER TABLE ONLY public.usertheme ALTER COLUMN id SET DEFAULT nextval('public.usertheme_id_seq'::regclass);
 ;   ALTER TABLE public.usertheme ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    308    307            �           2604    18817    veh_details id    DEFAULT     p   ALTER TABLE ONLY public.veh_details ALTER COLUMN id SET DEFAULT nextval('public.veh_details_id_seq'::regclass);
 =   ALTER TABLE public.veh_details ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    310    309            �           2604    18818    veh_fence id    DEFAULT     l   ALTER TABLE ONLY public.veh_fence ALTER COLUMN id SET DEFAULT nextval('public.veh_fence_id_seq'::regclass);
 ;   ALTER TABLE public.veh_fence ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    313    312            �           2604    18819    veh_info veh_id    DEFAULT     x   ALTER TABLE ONLY public.veh_info ALTER COLUMN veh_id SET DEFAULT nextval('public.veh_deviceinfo_veh_id_seq'::regclass);
 >   ALTER TABLE public.veh_info ALTER COLUMN veh_id DROP DEFAULT;
       public          postgres    false    311    246            �           2604    18820    veh_make makeid    DEFAULT     r   ALTER TABLE ONLY public.veh_make ALTER COLUMN makeid SET DEFAULT nextval('public.veh_make_makeid_seq'::regclass);
 >   ALTER TABLE public.veh_make ALTER COLUMN makeid DROP DEFAULT;
       public          postgres    false    315    314            �           2604    18821    veh_model id    DEFAULT     l   ALTER TABLE ONLY public.veh_model ALTER COLUMN id SET DEFAULT nextval('public.veh_model_id_seq'::regclass);
 ;   ALTER TABLE public.veh_model ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    317    316            �           2604    18822    veh_trip veh_trip_id    DEFAULT     |   ALTER TABLE ONLY public.veh_trip ALTER COLUMN veh_trip_id SET DEFAULT nextval('public.veh_trip_veh_trip_id_seq'::regclass);
 C   ALTER TABLE public.veh_trip ALTER COLUMN veh_trip_id DROP DEFAULT;
       public          postgres    false    319    318            �           2604    18823    vts_routes routeid    DEFAULT     x   ALTER TABLE ONLY public.vts_routes ALTER COLUMN routeid SET DEFAULT nextval('public.vts_routes_routeid_seq'::regclass);
 A   ALTER TABLE public.vts_routes ALTER COLUMN routeid DROP DEFAULT;
       public          postgres    false    322    321            �          0    18465    account_mobile_map 
   TABLE DATA           T   COPY public.account_mobile_map (account_id, plan_id, app_id, mobno, id) FROM stdin;
    public          postgres    false    216   H�      �          0    18471    alert 
   TABLE DATA           M   COPY public.alert (id, geoid, vehid, seen, userid, stat, "time") FROM stdin;
    public          postgres    false    218   e�      �          0    18478 	   alert_log 
   TABLE DATA           �   COPY public.alert_log (id, alert_uid, imei, veh_no, alert_type, lon, lat, status, rpt_src, rpt_date, device_status, geohash, remarks, speed, gf_id) FROM stdin;
    public          postgres    false    221   ��      �          0    18484    alert_settings 
   TABLE DATA           }   COPY public.alert_settings (id, alrtname, alrttype, active, pushurl, fleet, details, sendto, createdby, rds_raw) FROM stdin;
    public          postgres    false    222   ��      �          0    18490    app_routing_table 
   TABLE DATA           F   COPY public.app_routing_table (app_base_url, destination) FROM stdin;
    public          postgres    false    224   ��                 0    18494    channel_partner 
   TABLE DATA           }   COPY public.channel_partner (id, user_id, added_by, secmob, gst_no, company_name, active, logo, state, district) FROM stdin;
    public          postgres    false    226   ٻ                0    18500    count 
   TABLE DATA           &   COPY public.count (count) FROM stdin;
    public          postgres    false    227   0�                0    18503 	   cp_device 
   TABLE DATA           =   COPY public.cp_device (id, cp_userid, device_id) FROM stdin;
    public          postgres    false    228   M�                0    18507    crew 
   TABLE DATA           Q   COPY public.crew (c_id, name, emp_type, kyc_details, createdby, mob) FROM stdin;
    public          postgres    false    230   j�                0    18513    crew_veh 
   TABLE DATA           8   COPY public.crew_veh (cid, crew_id, veh_id) FROM stdin;
    public          postgres    false    232   ��                0    18517    dealer 
   TABLE DATA           �   COPY public.dealer (id, dealer_name, phone_num, sec_phn_num, mail, address, user_id, company_name, logo_filename, active, added_by, gst_no, district, state) FROM stdin;
    public          postgres    false    234   ��      	          0    18522    dealer_device 
   TABLE DATA           E   COPY public.dealer_device (id, dealer_userid, device_id) FROM stdin;
    public          postgres    false    235   �                0    18527    dev_otp 
   TABLE DATA           :   COPY public.dev_otp (id, imei, otphash, date) FROM stdin;
    public          postgres    false    238   (�      _          0    22984    devcnt 
   TABLE DATA           '   COPY public.devcnt (count) FROM stdin;
    public          postgres    false    323   E�                0    18534    device_block 
   TABLE DATA           V   COPY public.device_block (id, start, stop, count, dealer_userid, details) FROM stdin;
    public          postgres    false    240   d�      �          0    18452    device_details 
   TABLE DATA             COPY public.device_details (id, imei, serial_number, manufact_date, manufacturer, status, sim_no, sim_no2, manuf_id, iccid, restart_cnt, last_restart_date, dev_type, hw_license_id, sw_license_id, sw_licenseid, sim_no_validt, sim_no2_validt, m2m_provider) FROM stdin;
    public          postgres    false    215   ��                0    18566 	   districts 
   TABLE DATA           Q   COPY public.districts (district_id, district_name, state_id, active) FROM stdin;
    public          postgres    false    248   �                0    18573    imei_board_serial 
   TABLE DATA           ?   COPY public.imei_board_serial (imei, board_serial) FROM stdin;
    public          postgres    false    252   j�                0    18576    lc_data 
   TABLE DATA           �   COPY public.lc_data (lc_id, h3, h4, h5, h6, lat, lon, rg_loc_name, md_loc_name, dist, state, cntry, dt_status, active) FROM stdin;
    public          postgres    false    253   ��                0    18583    lc_data_old 
   TABLE DATA           �   COPY public.lc_data_old (lc_id, h3, h4, h5, h6, lat, lon, rg_loc_name, md_loc_name, dist, state, cntry, dt_status, active) FROM stdin;
    public          postgres    false    256   ��                0    18589 
   logincount 
   TABLE DATA           3   COPY public.logincount (userid, count) FROM stdin;
    public          postgres    false    257   ��                0    18592    menus 
   TABLE DATA           v   COPY public.menus (id, menu_name, menu_url, parent_menu, hassubmenu, layer, created_by, icon, view, type) FROM stdin;
    public          postgres    false    258   ޿      !          0    18599    mob_plan_details 
   TABLE DATA           F   COPY public.mob_plan_details (planid, plantype, planname) FROM stdin;
    public          postgres    false    260   �      #          0    18605    mob_plan_menu_map 
   TABLE DATA           L   COPY public.mob_plan_menu_map (plan_id, menu_type, menu_id, id) FROM stdin;
    public          postgres    false    262   %�      %          0    18611    mob_vehicle_map 
   TABLE DATA           �   COPY public.mob_vehicle_map (appid, mobno, veh_no, veh_name, imei, owner_id, owner_type, acc_type, acc_id, exp_date, id, plan_id) FROM stdin;
    public          postgres    false    264   B�      (          0    18620    product_master 
   TABLE DATA           H   COPY public.product_master (product, pcb, ems, slno, batch) FROM stdin;
    public          postgres    false    267   ��      )          0    18625    pwd_reset_log 
   TABLE DATA           R   COPY public.pwd_reset_log (id, userid, req_count, date, urlhash, otp) FROM stdin;
    public          postgres    false    268   ��      +          0    18632    report 
   TABLE DATA           L   COPY public.report (id, imei, userid, lats, date, "time", lngs) FROM stdin;
    public          postgres    false    270   ��      -          0    18638    request_notification 
   TABLE DATA           �   COPY public.request_notification (id, req_type, from_role, to_role, from_id, details, remarks, seen, status, response, product, to_id) FROM stdin;
    public          postgres    false    272   ��      .          0    18644 	   role_menu 
   TABLE DATA           E   COPY public.role_menu (role_id, menu_id, menu_order, id) FROM stdin;
    public          postgres    false    273   �      0          0    18648    roles 
   TABLE DATA           W   COPY public.roles (id, role_name, active, icon_class, plan_based, addedby) FROM stdin;
    public          postgres    false    275   ��      2          0    18654    route_fence 
   TABLE DATA           K   COPY public.route_fence (route_fence_id, route_id, fence_data) FROM stdin;
    public          postgres    false    277   �      3          0    18659    route_fences 
   TABLE DATA           N   COPY public.route_fences (route_fences_id, route_id, fenceid_gft) FROM stdin;
    public          postgres    false    278   6�      5          0    18663 
   route_trip 
   TABLE DATA           F   COPY public.route_trip (route_id, trip_id, route_trip_id) FROM stdin;
    public          postgres    false    280   S�      7          0    18667    sim_data 
   TABLE DATA           R   COPY public.sim_data (iccid1, msisdn1, imsi1, iccid2, imsi2, msisdn2) FROM stdin;
    public          postgres    false    282   p�      8          0    18672    states 
   TABLE DATA           >   COPY public.states (state_id, state_name, active) FROM stdin;
    public          postgres    false    283   ��                0    18541    subscription_details 
   TABLE DATA           �   COPY public.subscription_details (sub_id, user_id, entity_id, metering_type, start_date, end_date, status, entity_type, phonenumber, kyc_id, kyc_type, name, manuf_id, distr_id, franc_id, sub_period) FROM stdin;
    public          postgres    false    243   ��      a          0    22999    subscription_history 
   TABLE DATA           �   COPY public.subscription_history (id, sub_id, user_id, entity_id, start_date, end_date, status, phonenumber, kyc_id, kyc_type, name, manuf_id, distr_id, franc_id, sub_period, metering_type, entity_type, entry_date) FROM stdin;
    public          postgres    false    325   �      ;          0    18678    testmake 
   TABLE DATA           ,   COPY public.testmake (id, make) FROM stdin;
    public          postgres    false    286   ��      =          0    18684 	   testmodel 
   TABLE DATA           7   COPY public.testmodel (id, make_id, model) FROM stdin;
    public          postgres    false    288   ��      ?          0    18690    trip 
   TABLE DATA           G   COPY public.trip (tripid, fence, type, triplabel, details) FROM stdin;
    public          postgres    false    290   ��      @          0    18695 
   trip_fence 
   TABLE DATA           J   COPY public.trip_fence (trip_fence_id, trip_id, fence_id_gft) FROM stdin;
    public          postgres    false    291   ��      C          0    18700    tripschedule 
   TABLE DATA           C   COPY public.tripschedule (id, vehid, data, type, mode) FROM stdin;
    public          postgres    false    294   �      E          0    18706    url_mapping 
   TABLE DATA              COPY public.url_mapping (url_key, host, token_location, token_field_name, token_value, url_chop_portion, map_type) FROM stdin;
    public          postgres    false    296   .�      F          0    18711    user_edit_otp 
   TABLE DATA           K   COPY public.user_edit_otp (id, user_id, date, otphash, status) FROM stdin;
    public          postgres    false    297   ��      H          0    18717 
   user_fence 
   TABLE DATA           C   COPY public.user_fence (userid, fenceid, usr_fence_id) FROM stdin;
    public          postgres    false    299   ��      J          0    18721 
   user_roles 
   TABLE DATA           Y   COPY public.user_roles (user_id, role_id, active, default_role, addedby, id) FROM stdin;
    public          postgres    false    301   ��      L          0    18725    user_routing 
   TABLE DATA           5   COPY public.user_routing (id, uid, host) FROM stdin;
    public          postgres    false    303   <�                0    18546    user_veh 
   TABLE DATA           1   COPY public.user_veh (userid, vehid) FROM stdin;
    public          postgres    false    244   Y�                0    18549    userinfo 
   TABLE DATA           �   COPY public.userinfo (id, name, email, pwd, mobile, image_url, sec_mob, address, tenentid, addedby, active, manuf_id, distr_id, franc_id, user_type, app_id) FROM stdin;
    public          postgres    false    245   {�      O          0    18735 	   usertheme 
   TABLE DATA           @   COPY public.usertheme (id, userid, header, sidebar) FROM stdin;
    public          postgres    false    307   8�      Q          0    18741    veh_details 
   TABLE DATA           ]   COPY public.veh_details (veh_id, type, amount, start_date, end_date, number, id) FROM stdin;
    public          postgres    false    309   U�      T          0    18748 	   veh_fence 
   TABLE DATA           N   COPY public.veh_fence (id, vehid, fenceid, type, details, "time") FROM stdin;
    public          postgres    false    312   r�                0    18556    veh_info 
   TABLE DATA           �   COPY public.veh_info (veh_id, veh_no, imei, veh_type, veh_category, veh_class, "Veh_group", colour, "Veh_make", model, "Manfc_year", "Veh_name", dev_manuf_id, dev_distr_id, dev_franc_id) FROM stdin;
    public          postgres    false    246   ��      V          0    18754    veh_make 
   TABLE DATA           0   COPY public.veh_make (makeid, make) FROM stdin;
    public          postgres    false    314   ��      X          0    18760 	   veh_model 
   TABLE DATA           7   COPY public.veh_model (id, make_id, model) FROM stdin;
    public          postgres    false    316   ��      Z          0    18766    veh_trip 
   TABLE DATA           @   COPY public.veh_trip (veh_trip_id, veh_id, trip_id) FROM stdin;
    public          postgres    false    318   �      \          0    18770    vlt_details 
   TABLE DATA           9   COPY public.vlt_details (imei, iccid, sl_no) FROM stdin;
    public          postgres    false    320   ,�      ]          0    18775 
   vts_routes 
   TABLE DATA           k   COPY public.vts_routes (routeid, routename, createdby, createddate, totaldistance, routelabel) FROM stdin;
    public          postgres    false    321   I�      �           0    0    account_mobile_map_id_seq    SEQUENCE SET     H   SELECT pg_catalog.setval('public.account_mobile_map_id_seq', 1, false);
          public          postgres    false    217            �           0    0    alert_id_seq    SEQUENCE SET     ;   SELECT pg_catalog.setval('public.alert_id_seq', 1, false);
          public          postgres    false    219            �           0    0    alert_log_id_seq    SEQUENCE SET     ?   SELECT pg_catalog.setval('public.alert_log_id_seq', 1, false);
          public          postgres    false    220            �           0    0    alert_settings_id_seq    SEQUENCE SET     D   SELECT pg_catalog.setval('public.alert_settings_id_seq', 1, false);
          public          postgres    false    223            �           0    0    channel_partner_id_seq    SEQUENCE SET     D   SELECT pg_catalog.setval('public.channel_partner_id_seq', 4, true);
          public          postgres    false    225            �           0    0    cp_device_id_seq    SEQUENCE SET     ?   SELECT pg_catalog.setval('public.cp_device_id_seq', 1, false);
          public          postgres    false    229            �           0    0    crew_c_id_seq    SEQUENCE SET     <   SELECT pg_catalog.setval('public.crew_c_id_seq', 1, false);
          public          postgres    false    231            �           0    0    crew_veh_cid_seq    SEQUENCE SET     ?   SELECT pg_catalog.setval('public.crew_veh_cid_seq', 1, false);
          public          postgres    false    233            �           0    0    dealer_device_id_seq    SEQUENCE SET     C   SELECT pg_catalog.setval('public.dealer_device_id_seq', 1, false);
          public          postgres    false    236            �           0    0    dealer_id_seq    SEQUENCE SET     ;   SELECT pg_catalog.setval('public.dealer_id_seq', 4, true);
          public          postgres    false    237            �           0    0    dev_otp_id_seq    SEQUENCE SET     =   SELECT pg_catalog.setval('public.dev_otp_id_seq', 1, false);
          public          postgres    false    239            �           0    0    device_block_id_seq    SEQUENCE SET     B   SELECT pg_catalog.setval('public.device_block_id_seq', 1, false);
          public          postgres    false    241            �           0    0    device_details_id_seq    SEQUENCE SET     C   SELECT pg_catalog.setval('public.device_details_id_seq', 4, true);
          public          postgres    false    242            �           0    0    districts_district_id_seq    SEQUENCE SET     H   SELECT pg_catalog.setval('public.districts_district_id_seq', 1, false);
          public          postgres    false    249            �           0    0    fence_gft_gft_id_seq    SEQUENCE SET     C   SELECT pg_catalog.setval('public.fence_gft_gft_id_seq', 1, false);
          public          postgres    false    250            �           0    0    fence_id_seq    SEQUENCE SET     ;   SELECT pg_catalog.setval('public.fence_id_seq', 1, false);
          public          postgres    false    251            �           0    0    lc_data_1_lc_id_seq    SEQUENCE SET     B   SELECT pg_catalog.setval('public.lc_data_1_lc_id_seq', 1, false);
          public          postgres    false    254            �           0    0    lc_data_lc_id_seq    SEQUENCE SET     @   SELECT pg_catalog.setval('public.lc_data_lc_id_seq', 1, false);
          public          postgres    false    255            �           0    0    menus_id_seq    SEQUENCE SET     ;   SELECT pg_catalog.setval('public.menus_id_seq', 63, true);
          public          postgres    false    259            �           0    0    mob_plan_details_planid_seq    SEQUENCE SET     J   SELECT pg_catalog.setval('public.mob_plan_details_planid_seq', 1, false);
          public          postgres    false    261            �           0    0    mob_plan_menu_map_id_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('public.mob_plan_menu_map_id_seq', 1, false);
          public          postgres    false    263            �           0    0    mob_vehicle_map_id_seq    SEQUENCE SET     D   SELECT pg_catalog.setval('public.mob_vehicle_map_id_seq', 4, true);
          public          postgres    false    265            �           0    0    notifications_id_seq    SEQUENCE SET     C   SELECT pg_catalog.setval('public.notifications_id_seq', 1, false);
          public          postgres    false    266            �           0    0    pwd_reset_log_id_seq    SEQUENCE SET     C   SELECT pg_catalog.setval('public.pwd_reset_log_id_seq', 1, false);
          public          postgres    false    269            �           0    0    report_id_seq    SEQUENCE SET     <   SELECT pg_catalog.setval('public.report_id_seq', 1, false);
          public          postgres    false    271            �           0    0    role_menu_id_seq    SEQUENCE SET     @   SELECT pg_catalog.setval('public.role_menu_id_seq', 193, true);
          public          postgres    false    274            �           0    0    roles_id_seq    SEQUENCE SET     ;   SELECT pg_catalog.setval('public.roles_id_seq', 1, false);
          public          postgres    false    276            �           0    0     route_fences_route_fences_id_seq    SEQUENCE SET     O   SELECT pg_catalog.setval('public.route_fences_route_fences_id_seq', 1, false);
          public          postgres    false    279            �           0    0    route_trip_route_trip_id_seq    SEQUENCE SET     K   SELECT pg_catalog.setval('public.route_trip_route_trip_id_seq', 1, false);
          public          postgres    false    281            �           0    0    states_state_id_seq    SEQUENCE SET     B   SELECT pg_catalog.setval('public.states_state_id_seq', 1, false);
          public          postgres    false    284            �           0    0    subscription_details_sub_id_seq    SEQUENCE SET     M   SELECT pg_catalog.setval('public.subscription_details_sub_id_seq', 6, true);
          public          postgres    false    285            �           0    0    subscription_history_id_seq    SEQUENCE SET     I   SELECT pg_catalog.setval('public.subscription_history_id_seq', 8, true);
          public          postgres    false    324            �           0    0    testmake_id_seq    SEQUENCE SET     >   SELECT pg_catalog.setval('public.testmake_id_seq', 1, false);
          public          postgres    false    287            �           0    0    testmodel_id_seq    SEQUENCE SET     ?   SELECT pg_catalog.setval('public.testmodel_id_seq', 1, false);
          public          postgres    false    289            �           0    0    trip_fence_trip_fence_id_seq    SEQUENCE SET     K   SELECT pg_catalog.setval('public.trip_fence_trip_fence_id_seq', 1, false);
          public          postgres    false    292            �           0    0    trip_tripid_seq    SEQUENCE SET     >   SELECT pg_catalog.setval('public.trip_tripid_seq', 1, false);
          public          postgres    false    293            �           0    0    tripschedule_id_seq    SEQUENCE SET     B   SELECT pg_catalog.setval('public.tripschedule_id_seq', 1, false);
          public          postgres    false    295            �           0    0    user_edit_otp_id_seq    SEQUENCE SET     C   SELECT pg_catalog.setval('public.user_edit_otp_id_seq', 1, false);
          public          postgres    false    298            �           0    0    user_fence_usr_fence_id_seq    SEQUENCE SET     J   SELECT pg_catalog.setval('public.user_fence_usr_fence_id_seq', 1, false);
          public          postgres    false    300            �           0    0    user_roles_id_seq    SEQUENCE SET     @   SELECT pg_catalog.setval('public.user_roles_id_seq', 18, true);
          public          postgres    false    302            �           0    0    user_routing_id_seq    SEQUENCE SET     B   SELECT pg_catalog.setval('public.user_routing_id_seq', 1, false);
          public          postgres    false    304            �           0    0    userinfo_id_seq    SEQUENCE SET     >   SELECT pg_catalog.setval('public.userinfo_id_seq', 21, true);
          public          postgres    false    306            �           0    0    usertheme_id_seq    SEQUENCE SET     ?   SELECT pg_catalog.setval('public.usertheme_id_seq', 1, false);
          public          postgres    false    308            �           0    0    veh_details_id_seq    SEQUENCE SET     A   SELECT pg_catalog.setval('public.veh_details_id_seq', 1, false);
          public          postgres    false    310            �           0    0    veh_deviceinfo_veh_id_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('public.veh_deviceinfo_veh_id_seq', 4, true);
          public          postgres    false    311            �           0    0    veh_fence_id_seq    SEQUENCE SET     ?   SELECT pg_catalog.setval('public.veh_fence_id_seq', 1, false);
          public          postgres    false    313            �           0    0    veh_make_makeid_seq    SEQUENCE SET     B   SELECT pg_catalog.setval('public.veh_make_makeid_seq', 1, false);
          public          postgres    false    315            �           0    0    veh_model_id_seq    SEQUENCE SET     ?   SELECT pg_catalog.setval('public.veh_model_id_seq', 1, false);
          public          postgres    false    317            �           0    0    veh_trip_veh_trip_id_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('public.veh_trip_veh_trip_id_seq', 1, false);
          public          postgres    false    319            �           0    0    vts_routes_routeid_seq    SEQUENCE SET     E   SELECT pg_catalog.setval('public.vts_routes_routeid_seq', 1, false);
          public          postgres    false    322            �           2606    18825    alert_log alert_log_pkey 
   CONSTRAINT     V   ALTER TABLE ONLY public.alert_log
    ADD CONSTRAINT alert_log_pkey PRIMARY KEY (id);
 B   ALTER TABLE ONLY public.alert_log DROP CONSTRAINT alert_log_pkey;
       public            postgres    false    221            �           2606    18827    alert alert_pkey 
   CONSTRAINT     N   ALTER TABLE ONLY public.alert
    ADD CONSTRAINT alert_pkey PRIMARY KEY (id);
 :   ALTER TABLE ONLY public.alert DROP CONSTRAINT alert_pkey;
       public            postgres    false    218            �           2606    18829 $   channel_partner channel_partner_pkey 
   CONSTRAINT     b   ALTER TABLE ONLY public.channel_partner
    ADD CONSTRAINT channel_partner_pkey PRIMARY KEY (id);
 N   ALTER TABLE ONLY public.channel_partner DROP CONSTRAINT channel_partner_pkey;
       public            postgres    false    226            �           2606    18831    cp_device cp_device_pkey 
   CONSTRAINT     V   ALTER TABLE ONLY public.cp_device
    ADD CONSTRAINT cp_device_pkey PRIMARY KEY (id);
 B   ALTER TABLE ONLY public.cp_device DROP CONSTRAINT cp_device_pkey;
       public            postgres    false    228            �           2606    18833    crew_veh crew_veh_pkey 
   CONSTRAINT     U   ALTER TABLE ONLY public.crew_veh
    ADD CONSTRAINT crew_veh_pkey PRIMARY KEY (cid);
 @   ALTER TABLE ONLY public.crew_veh DROP CONSTRAINT crew_veh_pkey;
       public            postgres    false    232            �           2606    18835    dev_otp dev_otp_pkey 
   CONSTRAINT     R   ALTER TABLE ONLY public.dev_otp
    ADD CONSTRAINT dev_otp_pkey PRIMARY KEY (id);
 >   ALTER TABLE ONLY public.dev_otp DROP CONSTRAINT dev_otp_pkey;
       public            postgres    false    238            �           2606    18837    device_block device_block_pkey 
   CONSTRAINT     \   ALTER TABLE ONLY public.device_block
    ADD CONSTRAINT device_block_pkey PRIMARY KEY (id);
 H   ALTER TABLE ONLY public.device_block DROP CONSTRAINT device_block_pkey;
       public            postgres    false    240            �           2606    18839 "   device_details device_details_pkey 
   CONSTRAINT     `   ALTER TABLE ONLY public.device_details
    ADD CONSTRAINT device_details_pkey PRIMARY KEY (id);
 L   ALTER TABLE ONLY public.device_details DROP CONSTRAINT device_details_pkey;
       public            postgres    false    215            �           2606    18841 %   districts districts_district_name_key 
   CONSTRAINT     i   ALTER TABLE ONLY public.districts
    ADD CONSTRAINT districts_district_name_key UNIQUE (district_name);
 O   ALTER TABLE ONLY public.districts DROP CONSTRAINT districts_district_name_key;
       public            postgres    false    248            �           2606    18843    districts districts_pkey 
   CONSTRAINT     _   ALTER TABLE ONLY public.districts
    ADD CONSTRAINT districts_pkey PRIMARY KEY (district_id);
 B   ALTER TABLE ONLY public.districts DROP CONSTRAINT districts_pkey;
       public            postgres    false    248            �           2606    18845    userinfo email_unique 
   CONSTRAINT     Q   ALTER TABLE ONLY public.userinfo
    ADD CONSTRAINT email_unique UNIQUE (email);
 ?   ALTER TABLE ONLY public.userinfo DROP CONSTRAINT email_unique;
       public            postgres    false    245            �           2606    18847 "   subscription_details entity_id_uni 
   CONSTRAINT     b   ALTER TABLE ONLY public.subscription_details
    ADD CONSTRAINT entity_id_uni UNIQUE (entity_id);
 L   ALTER TABLE ONLY public.subscription_details DROP CONSTRAINT entity_id_uni;
       public            postgres    false    243            �           2606    18849 4   imei_board_serial imei_board_serial_board_serial_key 
   CONSTRAINT     w   ALTER TABLE ONLY public.imei_board_serial
    ADD CONSTRAINT imei_board_serial_board_serial_key UNIQUE (board_serial);
 ^   ALTER TABLE ONLY public.imei_board_serial DROP CONSTRAINT imei_board_serial_board_serial_key;
       public            postgres    false    252            �           2606    18851 (   imei_board_serial imei_board_serial_pkey 
   CONSTRAINT     h   ALTER TABLE ONLY public.imei_board_serial
    ADD CONSTRAINT imei_board_serial_pkey PRIMARY KEY (imei);
 R   ALTER TABLE ONLY public.imei_board_serial DROP CONSTRAINT imei_board_serial_pkey;
       public            postgres    false    252            �           2606    18853    device_details imei_unique 
   CONSTRAINT     U   ALTER TABLE ONLY public.device_details
    ADD CONSTRAINT imei_unique UNIQUE (imei);
 D   ALTER TABLE ONLY public.device_details DROP CONSTRAINT imei_unique;
       public            postgres    false    215            �           2606    18855    lc_data_old lc_data_pkey 
   CONSTRAINT     Y   ALTER TABLE ONLY public.lc_data_old
    ADD CONSTRAINT lc_data_pkey PRIMARY KEY (lc_id);
 B   ALTER TABLE ONLY public.lc_data_old DROP CONSTRAINT lc_data_pkey;
       public            postgres    false    256            �           2606    18857    lc_data lc_data_pkey1 
   CONSTRAINT     V   ALTER TABLE ONLY public.lc_data
    ADD CONSTRAINT lc_data_pkey1 PRIMARY KEY (lc_id);
 ?   ALTER TABLE ONLY public.lc_data DROP CONSTRAINT lc_data_pkey1;
       public            postgres    false    253            �           2606    18859     logincount logincount_userid_key 
   CONSTRAINT     ]   ALTER TABLE ONLY public.logincount
    ADD CONSTRAINT logincount_userid_key UNIQUE (userid);
 J   ALTER TABLE ONLY public.logincount DROP CONSTRAINT logincount_userid_key;
       public            postgres    false    257            �           2606    18861    menus menus_pkey 
   CONSTRAINT     N   ALTER TABLE ONLY public.menus
    ADD CONSTRAINT menus_pkey PRIMARY KEY (id);
 :   ALTER TABLE ONLY public.menus DROP CONSTRAINT menus_pkey;
       public            postgres    false    258            �           2606    18863 &   mob_plan_details mob_plan_details_pkey 
   CONSTRAINT     h   ALTER TABLE ONLY public.mob_plan_details
    ADD CONSTRAINT mob_plan_details_pkey PRIMARY KEY (planid);
 P   ALTER TABLE ONLY public.mob_plan_details DROP CONSTRAINT mob_plan_details_pkey;
       public            postgres    false    260                       2606    18865 (   mob_plan_menu_map mob_plan_menu_map_pkey 
   CONSTRAINT     f   ALTER TABLE ONLY public.mob_plan_menu_map
    ADD CONSTRAINT mob_plan_menu_map_pkey PRIMARY KEY (id);
 R   ALTER TABLE ONLY public.mob_plan_menu_map DROP CONSTRAINT mob_plan_menu_map_pkey;
       public            postgres    false    262                       2606    18867 $   mob_vehicle_map mob_vehicle_map_pkey 
   CONSTRAINT     b   ALTER TABLE ONLY public.mob_vehicle_map
    ADD CONSTRAINT mob_vehicle_map_pkey PRIMARY KEY (id);
 N   ALTER TABLE ONLY public.mob_vehicle_map DROP CONSTRAINT mob_vehicle_map_pkey;
       public            postgres    false    264            �           2606    18869    userinfo mobile_unique 
   CONSTRAINT     S   ALTER TABLE ONLY public.userinfo
    ADD CONSTRAINT mobile_unique UNIQUE (mobile);
 @   ALTER TABLE ONLY public.userinfo DROP CONSTRAINT mobile_unique;
       public            postgres    false    245            	           2606    18871 '   request_notification notifications_pkey 
   CONSTRAINT     e   ALTER TABLE ONLY public.request_notification
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (id);
 Q   ALTER TABLE ONLY public.request_notification DROP CONSTRAINT notifications_pkey;
       public            postgres    false    272                       2606    18873     pwd_reset_log pwd_reset_log_pkey 
   CONSTRAINT     ^   ALTER TABLE ONLY public.pwd_reset_log
    ADD CONSTRAINT pwd_reset_log_pkey PRIMARY KEY (id);
 J   ALTER TABLE ONLY public.pwd_reset_log DROP CONSTRAINT pwd_reset_log_pkey;
       public            postgres    false    268                       2606    18875    report report_pkey 
   CONSTRAINT     P   ALTER TABLE ONLY public.report
    ADD CONSTRAINT report_pkey PRIMARY KEY (id);
 <   ALTER TABLE ONLY public.report DROP CONSTRAINT report_pkey;
       public            postgres    false    270                       2606    18877    role_menu role_menu_pkey 
   CONSTRAINT     V   ALTER TABLE ONLY public.role_menu
    ADD CONSTRAINT role_menu_pkey PRIMARY KEY (id);
 B   ALTER TABLE ONLY public.role_menu DROP CONSTRAINT role_menu_pkey;
       public            postgres    false    273                       2606    18879    roles roles_pkey 
   CONSTRAINT     N   ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);
 :   ALTER TABLE ONLY public.roles DROP CONSTRAINT roles_pkey;
       public            postgres    false    275                       2606    18881    roles roles_role_name_key 
   CONSTRAINT     Y   ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_role_name_key UNIQUE (role_name);
 C   ALTER TABLE ONLY public.roles DROP CONSTRAINT roles_role_name_key;
       public            postgres    false    275                       2606    18883    route_fence route_fence_pkey 
   CONSTRAINT     f   ALTER TABLE ONLY public.route_fence
    ADD CONSTRAINT route_fence_pkey PRIMARY KEY (route_fence_id);
 F   ALTER TABLE ONLY public.route_fence DROP CONSTRAINT route_fence_pkey;
       public            postgres    false    277                       2606    18885    route_fences route_fences_pkey 
   CONSTRAINT     i   ALTER TABLE ONLY public.route_fences
    ADD CONSTRAINT route_fences_pkey PRIMARY KEY (route_fences_id);
 H   ALTER TABLE ONLY public.route_fences DROP CONSTRAINT route_fences_pkey;
       public            postgres    false    278                       2606    18887    route_trip route_trip_pkey 
   CONSTRAINT     c   ALTER TABLE ONLY public.route_trip
    ADD CONSTRAINT route_trip_pkey PRIMARY KEY (route_trip_id);
 D   ALTER TABLE ONLY public.route_trip DROP CONSTRAINT route_trip_pkey;
       public            postgres    false    280                       2606    18889    sim_data sim_data_pkey 
   CONSTRAINT     X   ALTER TABLE ONLY public.sim_data
    ADD CONSTRAINT sim_data_pkey PRIMARY KEY (iccid1);
 @   ALTER TABLE ONLY public.sim_data DROP CONSTRAINT sim_data_pkey;
       public            postgres    false    282                       2606    18891    states states_pkey 
   CONSTRAINT     V   ALTER TABLE ONLY public.states
    ADD CONSTRAINT states_pkey PRIMARY KEY (state_id);
 <   ALTER TABLE ONLY public.states DROP CONSTRAINT states_pkey;
       public            postgres    false    283                       2606    18893    states states_state_name_key 
   CONSTRAINT     ]   ALTER TABLE ONLY public.states
    ADD CONSTRAINT states_state_name_key UNIQUE (state_name);
 F   ALTER TABLE ONLY public.states DROP CONSTRAINT states_state_name_key;
       public            postgres    false    283            �           2606    18895 .   subscription_details subscription_details_pkey 
   CONSTRAINT     p   ALTER TABLE ONLY public.subscription_details
    ADD CONSTRAINT subscription_details_pkey PRIMARY KEY (sub_id);
 X   ALTER TABLE ONLY public.subscription_details DROP CONSTRAINT subscription_details_pkey;
       public            postgres    false    243            C           2606    23006 .   subscription_history subscription_history_pkey 
   CONSTRAINT     l   ALTER TABLE ONLY public.subscription_history
    ADD CONSTRAINT subscription_history_pkey PRIMARY KEY (id);
 X   ALTER TABLE ONLY public.subscription_history DROP CONSTRAINT subscription_history_pkey;
       public            postgres    false    325                       2606    18897    testmake testmake_pkey 
   CONSTRAINT     T   ALTER TABLE ONLY public.testmake
    ADD CONSTRAINT testmake_pkey PRIMARY KEY (id);
 @   ALTER TABLE ONLY public.testmake DROP CONSTRAINT testmake_pkey;
       public            postgres    false    286                       2606    18899    testmodel testmodel_pkey 
   CONSTRAINT     V   ALTER TABLE ONLY public.testmodel
    ADD CONSTRAINT testmodel_pkey PRIMARY KEY (id);
 B   ALTER TABLE ONLY public.testmodel DROP CONSTRAINT testmodel_pkey;
       public            postgres    false    288            #           2606    18901    trip_fence trip_fence_pkey 
   CONSTRAINT     c   ALTER TABLE ONLY public.trip_fence
    ADD CONSTRAINT trip_fence_pkey PRIMARY KEY (trip_fence_id);
 D   ALTER TABLE ONLY public.trip_fence DROP CONSTRAINT trip_fence_pkey;
       public            postgres    false    291            !           2606    18903    trip trip_pkey 
   CONSTRAINT     P   ALTER TABLE ONLY public.trip
    ADD CONSTRAINT trip_pkey PRIMARY KEY (tripid);
 8   ALTER TABLE ONLY public.trip DROP CONSTRAINT trip_pkey;
       public            postgres    false    290            %           2606    18905    tripschedule tripschedule_pkey 
   CONSTRAINT     \   ALTER TABLE ONLY public.tripschedule
    ADD CONSTRAINT tripschedule_pkey PRIMARY KEY (id);
 H   ALTER TABLE ONLY public.tripschedule DROP CONSTRAINT tripschedule_pkey;
       public            postgres    false    294            '           2606    18907    url_mapping url_mapping_pkey 
   CONSTRAINT     _   ALTER TABLE ONLY public.url_mapping
    ADD CONSTRAINT url_mapping_pkey PRIMARY KEY (url_key);
 F   ALTER TABLE ONLY public.url_mapping DROP CONSTRAINT url_mapping_pkey;
       public            postgres    false    296            )           2606    18909     user_edit_otp user_edit_otp_pkey 
   CONSTRAINT     ^   ALTER TABLE ONLY public.user_edit_otp
    ADD CONSTRAINT user_edit_otp_pkey PRIMARY KEY (id);
 J   ALTER TABLE ONLY public.user_edit_otp DROP CONSTRAINT user_edit_otp_pkey;
       public            postgres    false    297            +           2606    18911    user_fence user_fence_pkey 
   CONSTRAINT     b   ALTER TABLE ONLY public.user_fence
    ADD CONSTRAINT user_fence_pkey PRIMARY KEY (usr_fence_id);
 D   ALTER TABLE ONLY public.user_fence DROP CONSTRAINT user_fence_pkey;
       public            postgres    false    299            -           2606    18913    user_roles user_roles_pkey 
   CONSTRAINT     X   ALTER TABLE ONLY public.user_roles
    ADD CONSTRAINT user_roles_pkey PRIMARY KEY (id);
 D   ALTER TABLE ONLY public.user_roles DROP CONSTRAINT user_roles_pkey;
       public            postgres    false    301            /           2606    18915    user_routing user_routing_pkey 
   CONSTRAINT     \   ALTER TABLE ONLY public.user_routing
    ADD CONSTRAINT user_routing_pkey PRIMARY KEY (id);
 H   ALTER TABLE ONLY public.user_routing DROP CONSTRAINT user_routing_pkey;
       public            postgres    false    303            �           2606    18917    userinfo userinfo_email_key 
   CONSTRAINT     W   ALTER TABLE ONLY public.userinfo
    ADD CONSTRAINT userinfo_email_key UNIQUE (email);
 E   ALTER TABLE ONLY public.userinfo DROP CONSTRAINT userinfo_email_key;
       public            postgres    false    245            �           2606    18919    userinfo userinfo_pkey 
   CONSTRAINT     T   ALTER TABLE ONLY public.userinfo
    ADD CONSTRAINT userinfo_pkey PRIMARY KEY (id);
 @   ALTER TABLE ONLY public.userinfo DROP CONSTRAINT userinfo_pkey;
       public            postgres    false    245            1           2606    18921    usertheme usertheme_pkey 
   CONSTRAINT     V   ALTER TABLE ONLY public.usertheme
    ADD CONSTRAINT usertheme_pkey PRIMARY KEY (id);
 B   ALTER TABLE ONLY public.usertheme DROP CONSTRAINT usertheme_pkey;
       public            postgres    false    307            3           2606    18923    veh_details veh_details_pkey 
   CONSTRAINT     Z   ALTER TABLE ONLY public.veh_details
    ADD CONSTRAINT veh_details_pkey PRIMARY KEY (id);
 F   ALTER TABLE ONLY public.veh_details DROP CONSTRAINT veh_details_pkey;
       public            postgres    false    309            �           2606    18925    veh_info veh_deviceinfo_pkey 
   CONSTRAINT     ^   ALTER TABLE ONLY public.veh_info
    ADD CONSTRAINT veh_deviceinfo_pkey PRIMARY KEY (veh_id);
 F   ALTER TABLE ONLY public.veh_info DROP CONSTRAINT veh_deviceinfo_pkey;
       public            postgres    false    246            5           2606    18927    veh_fence veh_fence_pkey 
   CONSTRAINT     V   ALTER TABLE ONLY public.veh_fence
    ADD CONSTRAINT veh_fence_pkey PRIMARY KEY (id);
 B   ALTER TABLE ONLY public.veh_fence DROP CONSTRAINT veh_fence_pkey;
       public            postgres    false    312            7           2606    18929    veh_make veh_make_make_key 
   CONSTRAINT     U   ALTER TABLE ONLY public.veh_make
    ADD CONSTRAINT veh_make_make_key UNIQUE (make);
 D   ALTER TABLE ONLY public.veh_make DROP CONSTRAINT veh_make_make_key;
       public            postgres    false    314            9           2606    18931    veh_make veh_make_pkey 
   CONSTRAINT     X   ALTER TABLE ONLY public.veh_make
    ADD CONSTRAINT veh_make_pkey PRIMARY KEY (makeid);
 @   ALTER TABLE ONLY public.veh_make DROP CONSTRAINT veh_make_pkey;
       public            postgres    false    314            ;           2606    18933    veh_model veh_model_pkey 
   CONSTRAINT     V   ALTER TABLE ONLY public.veh_model
    ADD CONSTRAINT veh_model_pkey PRIMARY KEY (id);
 B   ALTER TABLE ONLY public.veh_model DROP CONSTRAINT veh_model_pkey;
       public            postgres    false    316            =           2606    18935    veh_trip veh_trip_pkey 
   CONSTRAINT     ]   ALTER TABLE ONLY public.veh_trip
    ADD CONSTRAINT veh_trip_pkey PRIMARY KEY (veh_trip_id);
 @   ALTER TABLE ONLY public.veh_trip DROP CONSTRAINT veh_trip_pkey;
       public            postgres    false    318            ?           2606    18937    vlt_details vlt_details_pk 
   CONSTRAINT     Z   ALTER TABLE ONLY public.vlt_details
    ADD CONSTRAINT vlt_details_pk PRIMARY KEY (imei);
 D   ALTER TABLE ONLY public.vlt_details DROP CONSTRAINT vlt_details_pk;
       public            postgres    false    320            A           2606    18939    vts_routes vts_routes_pkey 
   CONSTRAINT     ]   ALTER TABLE ONLY public.vts_routes
    ADD CONSTRAINT vts_routes_pkey PRIMARY KEY (routeid);
 D   ALTER TABLE ONLY public.vts_routes DROP CONSTRAINT vts_routes_pkey;
       public            postgres    false    321            �           1259    18940    rptdate_idx    INDEX     E   CREATE INDEX rptdate_idx ON public.alert_log USING btree (rpt_date);
    DROP INDEX public.rptdate_idx;
       public            postgres    false    221            D           2606    18941    alert alert_vehid_fkey    FK CONSTRAINT     z   ALTER TABLE ONLY public.alert
    ADD CONSTRAINT alert_vehid_fkey FOREIGN KEY (vehid) REFERENCES public.veh_info(veh_id);
 @   ALTER TABLE ONLY public.alert DROP CONSTRAINT alert_vehid_fkey;
       public          postgres    false    218    246    5101            E           2606    18946 "   cp_device cp_device_cp_userid_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.cp_device
    ADD CONSTRAINT cp_device_cp_userid_fkey FOREIGN KEY (cp_userid) REFERENCES public.userinfo(id) ON DELETE CASCADE;
 L   ALTER TABLE ONLY public.cp_device DROP CONSTRAINT cp_device_cp_userid_fkey;
       public          postgres    false    228    5099    245            F           2606    18951 "   cp_device cp_device_device_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.cp_device
    ADD CONSTRAINT cp_device_device_id_fkey FOREIGN KEY (device_id) REFERENCES public.device_details(id) ON DELETE CASCADE;
 L   ALTER TABLE ONLY public.cp_device DROP CONSTRAINT cp_device_device_id_fkey;
       public          postgres    false    5070    215    228            G           2606    18956    crew_veh crew_veh_veh_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.crew_veh
    ADD CONSTRAINT crew_veh_veh_id_fkey FOREIGN KEY (veh_id) REFERENCES public.veh_info(veh_id);
 G   ALTER TABLE ONLY public.crew_veh DROP CONSTRAINT crew_veh_veh_id_fkey;
       public          postgres    false    246    232    5101            H           2606    18961 *   dealer_device dealer_device_device_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.dealer_device
    ADD CONSTRAINT dealer_device_device_id_fkey FOREIGN KEY (device_id) REFERENCES public.device_details(id);
 T   ALTER TABLE ONLY public.dealer_device DROP CONSTRAINT dealer_device_device_id_fkey;
       public          postgres    false    5070    235    215            I           2606    18966 #   device_block device_block_from_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.device_block
    ADD CONSTRAINT device_block_from_fkey FOREIGN KEY (start) REFERENCES public.device_details(id);
 M   ALTER TABLE ONLY public.device_block DROP CONSTRAINT device_block_from_fkey;
       public          postgres    false    5070    215    240            J           2606    18971 !   device_block device_block_to_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.device_block
    ADD CONSTRAINT device_block_to_fkey FOREIGN KEY (stop) REFERENCES public.device_details(id);
 K   ALTER TABLE ONLY public.device_block DROP CONSTRAINT device_block_to_fkey;
       public          postgres    false    215    240    5070            L           2606    18976    menus fkmenus738411    FK CONSTRAINT     x   ALTER TABLE ONLY public.menus
    ADD CONSTRAINT fkmenus738411 FOREIGN KEY (created_by) REFERENCES public.userinfo(id);
 =   ALTER TABLE ONLY public.menus DROP CONSTRAINT fkmenus738411;
       public          postgres    false    258    245    5099            N           2606    18981    role_menu fkroles_menu664017    FK CONSTRAINT     �   ALTER TABLE ONLY public.role_menu
    ADD CONSTRAINT fkroles_menu664017 FOREIGN KEY (role_id) REFERENCES public.roles(id) ON DELETE CASCADE;
 F   ALTER TABLE ONLY public.role_menu DROP CONSTRAINT fkroles_menu664017;
       public          postgres    false    5133    273    275            O           2606    18986    role_menu fkroles_menu875123    FK CONSTRAINT     �   ALTER TABLE ONLY public.role_menu
    ADD CONSTRAINT fkroles_menu875123 FOREIGN KEY (menu_id) REFERENCES public.menus(id) ON DELETE CASCADE;
 F   ALTER TABLE ONLY public.role_menu DROP CONSTRAINT fkroles_menu875123;
       public          postgres    false    273    5117    258            Y           2606    18991    user_roles fkuser_roles621810    FK CONSTRAINT     �   ALTER TABLE ONLY public.user_roles
    ADD CONSTRAINT fkuser_roles621810 FOREIGN KEY (role_id) REFERENCES public.roles(id) ON DELETE CASCADE;
 G   ALTER TABLE ONLY public.user_roles DROP CONSTRAINT fkuser_roles621810;
       public          postgres    false    5133    275    301            Z           2606    18996    user_roles fkuser_roles673043    FK CONSTRAINT     �   ALTER TABLE ONLY public.user_roles
    ADD CONSTRAINT fkuser_roles673043 FOREIGN KEY (user_id) REFERENCES public.userinfo(id) ON DELETE CASCADE;
 G   ALTER TABLE ONLY public.user_roles DROP CONSTRAINT fkuser_roles673043;
       public          postgres    false    5099    245    301            M           2606    19001    menus menus_created_by_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.menus
    ADD CONSTRAINT menus_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.userinfo(id) ON DELETE CASCADE NOT VALID;
 E   ALTER TABLE ONLY public.menus DROP CONSTRAINT menus_created_by_fkey;
       public          postgres    false    245    258    5099            P           2606    19006     role_menu role_menu_menu_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.role_menu
    ADD CONSTRAINT role_menu_menu_id_fkey FOREIGN KEY (menu_id) REFERENCES public.menus(id) ON DELETE CASCADE;
 J   ALTER TABLE ONLY public.role_menu DROP CONSTRAINT role_menu_menu_id_fkey;
       public          postgres    false    273    5117    258            Q           2606    19011     role_menu role_menu_role_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.role_menu
    ADD CONSTRAINT role_menu_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.roles(id) ON DELETE CASCADE;
 J   ALTER TABLE ONLY public.role_menu DROP CONSTRAINT role_menu_role_id_fkey;
       public          postgres    false    275    273    5133            R           2606    19016    roles roles_addedby_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_addedby_fkey FOREIGN KEY (addedby) REFERENCES public.userinfo(id) ON DELETE CASCADE NOT VALID;
 B   ALTER TABLE ONLY public.roles DROP CONSTRAINT roles_addedby_fkey;
       public          postgres    false    275    245    5099            S           2606    19021 %   route_fence route_fence_route_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.route_fence
    ADD CONSTRAINT route_fence_route_id_fkey FOREIGN KEY (route_id) REFERENCES public.vts_routes(routeid) ON DELETE CASCADE;
 O   ALTER TABLE ONLY public.route_fence DROP CONSTRAINT route_fence_route_id_fkey;
       public          postgres    false    5185    277    321            T           2606    19026 '   route_fences route_fences_route_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.route_fences
    ADD CONSTRAINT route_fences_route_id_fkey FOREIGN KEY (route_id) REFERENCES public.vts_routes(routeid) ON DELETE CASCADE;
 Q   ALTER TABLE ONLY public.route_fences DROP CONSTRAINT route_fences_route_id_fkey;
       public          postgres    false    5185    321    278            U           2606    19031 #   route_trip route_trip_route_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.route_trip
    ADD CONSTRAINT route_trip_route_id_fkey FOREIGN KEY (route_id) REFERENCES public.vts_routes(routeid) ON DELETE CASCADE;
 M   ALTER TABLE ONLY public.route_trip DROP CONSTRAINT route_trip_route_id_fkey;
       public          postgres    false    5185    280    321            V           2606    19036 "   route_trip route_trip_trip_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.route_trip
    ADD CONSTRAINT route_trip_trip_id_fkey FOREIGN KEY (trip_id) REFERENCES public.trip(tripid) ON DELETE CASCADE;
 L   ALTER TABLE ONLY public.route_trip DROP CONSTRAINT route_trip_trip_id_fkey;
       public          postgres    false    280    5153    290            W           2606    19041 "   trip_fence trip_fence_trip_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.trip_fence
    ADD CONSTRAINT trip_fence_trip_id_fkey FOREIGN KEY (trip_id) REFERENCES public.trip(tripid) ON DELETE CASCADE;
 L   ALTER TABLE ONLY public.trip_fence DROP CONSTRAINT trip_fence_trip_id_fkey;
       public          postgres    false    5153    290    291            X           2606    19046 $   tripschedule tripschedule_vehid_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.tripschedule
    ADD CONSTRAINT tripschedule_vehid_fkey FOREIGN KEY (vehid) REFERENCES public.veh_info(veh_id) ON DELETE CASCADE;
 N   ALTER TABLE ONLY public.tripschedule DROP CONSTRAINT tripschedule_vehid_fkey;
       public          postgres    false    246    5101    294            [           2606    19051 "   user_roles user_roles_addedby_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.user_roles
    ADD CONSTRAINT user_roles_addedby_fkey FOREIGN KEY (addedby) REFERENCES public.userinfo(id) ON DELETE CASCADE NOT VALID;
 L   ALTER TABLE ONLY public.user_roles DROP CONSTRAINT user_roles_addedby_fkey;
       public          postgres    false    5099    245    301            \           2606    19056 "   user_roles user_roles_role_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.user_roles
    ADD CONSTRAINT user_roles_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.roles(id) ON DELETE CASCADE NOT VALID;
 L   ALTER TABLE ONLY public.user_roles DROP CONSTRAINT user_roles_role_id_fkey;
       public          postgres    false    275    5133    301            ]           2606    19061 "   user_roles user_roles_user_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.user_roles
    ADD CONSTRAINT user_roles_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.userinfo(id) ON DELETE CASCADE NOT VALID;
 L   ALTER TABLE ONLY public.user_roles DROP CONSTRAINT user_roles_user_id_fkey;
       public          postgres    false    5099    245    301            ^           2606    19066 "   user_routing user_routing_uid_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.user_routing
    ADD CONSTRAINT user_routing_uid_fkey FOREIGN KEY (uid) REFERENCES public.userinfo(id) ON DELETE CASCADE;
 L   ALTER TABLE ONLY public.user_routing DROP CONSTRAINT user_routing_uid_fkey;
       public          postgres    false    245    5099    303            K           2606    19071    user_veh user_veh_vehid_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.user_veh
    ADD CONSTRAINT user_veh_vehid_fkey FOREIGN KEY (vehid) REFERENCES public.veh_info(veh_id) ON DELETE CASCADE;
 F   ALTER TABLE ONLY public.user_veh DROP CONSTRAINT user_veh_vehid_fkey;
       public          postgres    false    244    5101    246            _           2606    19076 #   veh_details veh_details_veh_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.veh_details
    ADD CONSTRAINT veh_details_veh_id_fkey FOREIGN KEY (veh_id) REFERENCES public.veh_info(veh_id) ON DELETE CASCADE;
 M   ALTER TABLE ONLY public.veh_details DROP CONSTRAINT veh_details_veh_id_fkey;
       public          postgres    false    309    246    5101            `           2606    19081    veh_fence veh_fence_vehid_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.veh_fence
    ADD CONSTRAINT veh_fence_vehid_fkey FOREIGN KEY (vehid) REFERENCES public.veh_info(veh_id) ON DELETE CASCADE;
 H   ALTER TABLE ONLY public.veh_fence DROP CONSTRAINT veh_fence_vehid_fkey;
       public          postgres    false    246    5101    312            a           2606    19086     veh_model veh_model_make_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.veh_model
    ADD CONSTRAINT veh_model_make_id_fkey FOREIGN KEY (make_id) REFERENCES public.veh_make(makeid) ON DELETE CASCADE;
 J   ALTER TABLE ONLY public.veh_model DROP CONSTRAINT veh_model_make_id_fkey;
       public          postgres    false    316    5177    314            b           2606    19091    veh_trip veh_trip_trip_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.veh_trip
    ADD CONSTRAINT veh_trip_trip_id_fkey FOREIGN KEY (trip_id) REFERENCES public.trip(tripid) ON DELETE CASCADE;
 H   ALTER TABLE ONLY public.veh_trip DROP CONSTRAINT veh_trip_trip_id_fkey;
       public          postgres    false    290    318    5153            c           2606    19096    veh_trip veh_trip_veh_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.veh_trip
    ADD CONSTRAINT veh_trip_veh_id_fkey FOREIGN KEY (veh_id) REFERENCES public.veh_info(veh_id) ON DELETE CASCADE;
 G   ALTER TABLE ONLY public.veh_trip DROP CONSTRAINT veh_trip_veh_id_fkey;
       public          postgres    false    5101    246    318            �      x������ � �      �      x������ � �      �      x������ � �      �      x������ � �      �      x������ � �          G   x�3��4���4426153��t�,.)�L*-�/�,�pr�p�C���"+4��4����� j3            x������ � �            x������ � �            x������ � �            x������ � �         W   x�3��CA�F�.��9�E N	�	P����̌ӌӐ�C�T�L�����P�P�	�z#�zc�z#S#ccNs��=... �[~      	      x������ � �            x������ � �      _      x�3������ S �            x������ � �      �   `   x�3�0��4300310�443�4400�4202�50�52�tJ�KO��/J��s紴017 ��4��Â ���"��E�e�)�E\1z\\\ ��         i  x�m��N�0������5�~�d	6m��n��j��ɔ6������;v|���N�r�F�E6�x�Ak�P��>�E������vfx6c�:<�8g�(�NV�oa�����v�h�iX�3w
-6�"��T/�S��+�3���}���+���0n�g�e@�La�V�3�k��l�^*lЦ�v���|�{��b��T��To rX�?V�!['E��[E6[��#������9',?=�DX�9!��SR��b��zj�k�Fc�.�5jNn��a�T-��wn*I��%����,`<�,q�YF��-J�異u�S�(�/ŉ��0�g�+L�F�f����G�~3�� L��            x������ � �            x������ � �            x������ � �            x������ � �           x��W�r�8}���?��\�<fv^�*���>MUJ�lT%����m�$�P�I*8��p��� ��3Y?��FgY��u��ds��Rmr�&եo�,r�h�:b'�]H�~�\��!ǯ���ג��1\�I.c�.:	IN�1}� g�����6���ƛ�1��[�{W`�*��4B�9�Õ�D(�`u���\�1O�_��K�YGW��Q{�ǀ�Y�n��-g���r�7�����'F�Y<zbv8m1��N�=f Q&��)�Ɯ�����qFw&��*���*��TL�t���:i���IFA
�<�H�W�csn�z�����2sh��Z������m5�0�#q�2r�'�ӽ�Ͼ�_�����'~���LHb�or�?));U�O��ۣ�8�8��u4zh�MZ�VB-x��hWY���,p
6~�蟊c�:ĺj���Fp��>;��j�������{��Ϫ�wվ���Dթڨc(X���[sp�+��()q�ٗ�v0����ݮ����G��C�	TY�'�Pɨ�V̷ض�[1=���@3�g��J��O����H���|T �N��� GA��Oc?�zmL����H}�m@f�_@6�#��+�ƹ}���	��Z�nd�Ч��jɍC����ݡ'�K����<Υ����Gw�A�J��H����Ђ��7�$�	��fH���8pCt8��Y2ѻ�K�����Ө�݂�g,I�n�l� ֦?������[>�M�m,*ed�u��=�����o�ek��0@޺M��O�w���w�o0SM�0��?���6պ2�*�e����VjM�m�!���9oV�0B�[��4a�,-Y��zĢ}���i��e?��I�d� �\�����a�(I%�CmºİI���/�p� ��K�[�{v�a��z�V�����=q�L����Lb,�%�U�mP:��5Xܢ�p~o�X*n��E�E0�1�_{�2������9��2lњY{_��G�Fҽz	�E�#�_�V����*s_      !      x������ � �      #      x������ � �      %   E   x�=ɱ�0D���K����dP(i��@���ӑ8N��,��^}YA�������lTS �63{ )E�      (      x������ � �      )      x������ � �      +      x������ � �      -      x������ � �      .   m  x�%��u !C�PL�+M���_G$�e�x@��}�U����X��:�ٳ�,~H�>�˰]�\�˂X� 6B�g����؃�Y�x$C^;�}�$�|�!��5%���H,�l��F͆�,�P�,?
�����x�E ]b������"��������[���ē���X�E��-���h�`�D�1`h�d�
T��h��ii�xK9�6�j��(�e�NꙒ�C�,��b�&�ո��+��� K�hFK��/��X?�+��܀��X�����	�'�<�<�L=l��c�z��g��k�I�C�zZ#��%km�/����=Ìy5zÔu4{�����zԬo��tJ=֕���>��Q������?@u$      0   �   x�u��
�@E�_��h|��`'
��&n��2;��7v����{N�s�$����d�C�Q��/!���a_��s�CV��e���)�z�:~٢��#��^2�CM�.����'��/S2�_�ι7��O�      2      x������ � �      3      x������ � �      5      x������ � �      7      x������ � �      8   &   x�3��N-J�I�,�2�O-.QpJ�KO��c���� �N�         G   x�EƱ�0���K���X� )��A��s h����5�=���:՜��m�*ܘ�>�ΟP"lmf� =�7      a   s   x���1�0����.���u���.H��9hTD@�<���9Рe3�9���Uee��w>�=�1�~b�r�-cѪ�J+�O�O5���EM�"#{��	��}6�ǃ�vQ��m*�� �p/�      ;      x������ � �      =      x������ � �      ?      x������ � �      @      x������ � �      C      x������ � �      E   i   x�+-N-�M�KLO�M�+��())���742�3 BC+3�?*N-.���KM�*�L�+- Gs��*J-N%UOn~ ���8�J�e%ńU����� �zU}      F      x������ � �      H      x������ � �      J   K   x�E�Q
�0B��0c�i��e���i�J� Ou8��a��?v6���Y��e�.jV#��*u����Q�)x$�S�      L      x������ � �            x�32�4����� gS         �  x�}�IoA�ϝ_�!WB��]ݷ$$B���¥Wc�y��S�`ǘ$�Ӛ��h��{5ļ��&h�l������ϋ�:+���%8���PO�43C��YHj��)�(���4��}��"M��j�z9[L�~,�����������l�tk���ƀ�������r�4o�1�e�NݖR7�<�d{o)�bc/-�Ʈ�bh_O1���{�
���HE��ײ������r�c�@���$�Q����9q�k*D)"�JSjm��&,�D٭ǉ.j]�a $v;�Q(6�_�P2B��GP��U(ahɁc�){�SK�D�؁`f1��ֳP�ڭwj�5���K:D�(0�������1%�!��N������y�9=�r`�(�ErG8.�\c)���U\�9����'�Z(�D�ٵ����������N!�F}�>G���2HǍi�3j� TL˜���.��T@�(�DޭgM��'���ˋ��-�l�W�T�͖��JLT��Hu���'�-�ƍI+�.�����ǉ.����~���ϑWF��p��P��t>]���0�,��&*���!�h�Z�2���-
T)D�/���q��N��M�H�[�`&�n?޼{�����61�cd9�4~�f�`*��Z��O��٤�ZQ4#D�A;�[�:H���_�NNN� �x��      O      x������ � �      Q      x������ � �      T      x������ � �         6   x�3���106405�0��4300310�443�tv��ÎL8-8��b���� �E5      V      x������ � �      X      x������ � �      Z      x������ � �      \      x������ � �      ]      x������ � �     