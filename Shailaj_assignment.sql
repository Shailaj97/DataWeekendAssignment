CREATE TABLE physician (
employeeid INT PRIMARY KEY NOT NULL,
name TEXT ,
position TEXT ,
ssn INT
)

CREATE TABLE department (
departmentid INT PRIMARY KEY NOT NULL,
name TEXT NOT ,
head INT,
CONSTRAINT fk_department_physician
FOREIGN KEY(head) REFERENCES physician(employeeid)

)
CREATE TABLE affiliated_with (
physician INT,
department INT,
primaryaffiliation BOOLEAN NOT NULL,

CONSTRAINT fk_affiliated_with_physician
FOREIGN KEY(physician) REFERENCES physician(employeeid),

CONSTRAINT fk_affiliated_with_department
FOREIGN KEY(department) REFERENCES department(departmentid),

PRIMARY KEY (physician , department)

)

CREATE TABLE procedure (
code INT PRIMARY KEY NOT NULL,
name TEXT,
cost REAL

)


CREATE TABLE trained_in (
physician INT,
treatment INT,
certificationdate DATE,
certificationexpires DATE,

CONSTRAINT fk_trained_in_physician
FOREIGN KEY(physician) REFERENCES physician(employeeid),

CONSTRAINT fk_trained_in_procedure
FOREIGN KEY(treatment) REFERENCES procedure(code),

PRIMARY KEY (physician,treatment)

)

CREATE TABLE patient (
ssn INT PRIMARY KEY NOT NULL,
name TEXT,
address TEXT,
phone TEXT,
insuranceid INT UNIQUE,
pcp INT NOT NULL,

CONSTRAINT fk_patient_physician
FOREIGN KEY(pcp) REFERENCES physician(employeeid)

)

CREATE TABLE nurse (
employeeid INT PRIMARY KEY NOT NULL,
name TEXT,
position TEXT,
registered BOOLEAN NOT NULL,
sns INTEGER
)

CREATE TABLE appointment (
appointmentid INT PRIMARY KEY,
patient INT,
prepnurse INT,
physician INT,
start_dt_time TIMESTAMP ,
end_dt_time TIMESTAMP,
examinationroom TEXT,

CONSTRAINT fk_appointment_patient
FOREIGN KEY(patient) REFERENCES patient(ssn),

CONSTRAINT fk_appointment_nurse
FOREIGN KEY(prepnurse) REFERENCES nurse(employeeid),

CONSTRAINT fk_appointment_physician
FOREIGN KEY(physician) REFERENCES physician(employeeid)
)


CREATE TABLE medication (
code INT PRIMARY KEY NOT NULL,
name TEXT ,
brand TEXT,
description TEXT

)

CREATE TABLE prescribes (
physician INT,
patient INT,
medication INT,
date TIMESTAMP,
appointment INT,
dose TEXT,

CONSTRAINT fk_prescribes_physician
FOREIGN KEY(physician) REFERENCES physician(employeeid),

CONSTRAINT fk_prescribes_patient
FOREIGN KEY(patient) REFERENCES patient(ssn),

CONSTRAINT fk_prescribes_medication
FOREIGN KEY(medication) REFERENCES medication(code),

CONSTRAINT fk_prescribes_appointment
FOREIGN KEY(appointment) REFERENCES appointment(appointmentid),

PRIMARY KEY(physician,patient,medication,date)


)

CREATE TABLE block (
blockfloor INTE,
blockcode INT,
PRIMARY KEY(blockfloor,blockcode)
)

CREATE TABLE room (
roomnumber INT PRIMARY KEY NOT NULL,
roomtype TEXT,
blockfloor INT,
blockcode INT,
unavailable BOOLEAN NOT NULL,

CONSTRAINT fk_room_block
FOREIGN KEY(blockfloor,blockcode) REFERENCES block(blockfloor,blockcode)

)

CREATE TABLE on_call (
nurse INT,
blockfloor INT,
blockcode INT,
oncallstart TIMESTAMP,
oncallend TIMESTAMP,

CONSTRAINT fk_on_call_nurse
FOREIGN KEY(nurse) REFERENCES nurse(employeeid),

CONSTRAINT dk_on_call_block
FOREIGN KEY(blockfloor,blockcode) REFERENCES block(blockfloor,blockcode),

PRIMARY KEY(nurse,blockfloor,oncallstart,oncallend)

)

CREATE TABLE stay (
stayid INT PRIMARY KEY,
patient INT,
room INT,
start_time TIMESTAMP,
end_time TIMESTAMP,

CONSTRAINT fk_stay_patient
FOREIGN KEY(patient) REFERENCES patient(ssn),

CONSTRAINT fk_stay_room
FOREIGN KEY(room) REFERENCES room(roomnumber)

)

CREATE TABLE undergoes (
patient INT,
procedure INT,
stay INT,
date TIMESTAMP,
physician INT,
assistingnurse INT,

CONSTRAINT fk_undergoes_patient
FOREIGN KEY(patient) REFERENCES patient(ssn),

CONSTRAINT fk_undergoes_procedure
FOREIGN KEY(procedure) REFERENCES procedure(code),

CONSTRAINT fk_undergoes_stay
FOREIGN KEY(stay) REFERENCES stay(stayid),

CONSTRAINT fk_undergoes_physician
FOREIGN KEY(physician) REFERENCES physician(employeeid),

PRIMARY KEY(patient,procedure,stay,date)
)



SELECT physician.employeeid, physician.name as physician_name, department.name as department_name
FROM physician
INNER JOIN department ON physician.employeeid=department.head;


SELECT count( patient) AS Patients_who_have_taken_atleast_one_appointment
FROM appointment;


SELECT  physician.name as physician_name,department.name as department_name
FROM physician 
inner join affiliated_with on physician.employeeid=affiliated_with.physician
inner join  department on department.departmentid=affiliated_with.department;


SELECT unavailable, count(*)
FROM room
where unavailable='f'
GROUP BY unavailable


SELECT   physician.name
FROM physician 
inner join affiliated_with on physician.employeeid=affiliated_with.physician
inner join  department on department.departmentid=affiliated_with.department
where  department.name='Psychiatry';


SELECT   physician.name
FROM physician 
inner join affiliated_with on physician.employeeid=affiliated_with.physician
inner join  department on department.departmentid=affiliated_with.department
where affiliated_with.primaryaffiliation='f';


SELECT   physician.name
FROM physician 
inner join affiliated_with on physician.employeeid=affiliated_with.physician
inner join  department on department.departmentid=affiliated_with.department
where department.name='Surgery' or department.name=’Psychiatry’;


SELECT patient.name as Patient_name,count(appointment.patient) as No_of_Appointments
FROM appointment 
JOIN patient  ON appointment.patient=patient.ssn
GROUP BY patient.name
HAVING count(appointment.patient)>=1;


SELECT count(patient) 
FROM appointment
WHERE examinationroom='C';


SELECT   nurse.name, room.roomnumber
FROM nurse
inner join on_call on nurse.employeeid=on_call.nurse
inner join room on room.blockcode=on_call.blockcode;


SELECT   physician.name
FROM physician 
inner join affiliated_with on physician.employeeid=affiliated_with.physician
inner join  department on department.departmentid=affiliated_with.department
where department.name='Surgery' or department.name=’Psychiatry’;


SELECT   patient.name as patient_name ,room.blockcode ,room.blockfloor ,room.roomnumber
FROM patient
join stay on stay.patient=patient.ssn
join  room on room.roomnumber=stay.room


SELECT patient.name AS patient_name,physician.name AS physician_name, medication.name AS medication
FROM patient 
JOIN prescribes ON prescribes.patient=patient.ssn
JOIN physician ON physician.employeeid=prescribes.physician
JOIN medication ON prescribes.medication=medication.code
WHERE prescribes.appointment IS NOT NULL;


SELECT patient.name as patient_name, medication.name as medication_name
FROM patient
join prescribes on prescribes.patient=patient.ssn
join  medication on medication.code=prescribes.medication
where prescribes.appointment IS NULL;


SELECT patient.name as patient_name,physician.name as physician_name
FROM patient
join prescribes on prescribes.patient=patient.ssn
join  physician on physician.employeeid=prescribes.physician
join affiliated_with on physician.employeeid=affiliated_with.physician
where affiliated_with.department='1';


SELECT nurse.name AS nurse_name,on_call.blockcode AS block
FROM nurse 
JOIN on_call  ON on_call.nurse=nurse.employeeid;


SELECT patient.name AS patient_name,physician.name AS physician_name,nurse.name AS nurse_name,
 stay.end_time AS discharge_date,procedure.name as treatment,room.roomnumber AS room,
 room.blockfloor AS floor,room.blockcode AS block
FROM undergoes 
JOIN patient ON undergoes.patient=patient.ssn
JOIN physician  ON physician.employeeid=undergoes.physician
FULL OUTER JOIN nurse  ON nurse.employeeid=undergoes.assistingnurse
JOIN stay  ON undergoes.patient=stay.patient
JOIN room  ON stay.room=room.roomnumber
JOIN procedure  on undergoes.procedure=procedure.code;


SELECT nurse.name
FROM nurse
join on_call on on_call.nurse=nurse.employeeid
join room on room.blockfloor=on_call.blockfloor
where on_call.blockfloor = 1 and on_call.blockcode=3;
