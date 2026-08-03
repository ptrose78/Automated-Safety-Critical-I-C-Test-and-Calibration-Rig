BEGIN TRANSACTION;
CREATE TABLE IF NOT EXISTS "CalibrationPoints" (
	"PointID"	INTEGER,
	"RunID"	INTEGER NOT NULL,
	"StepPercent"	INTEGER NOT NULL,
	"AppliedReferenceValue"	REAL NOT NULL,
	"MeasuredSensorValue"	REAL NOT NULL,
	"CalculatedErrorPercent"	REAL NOT NULL,
	"PointPassFail"	INTEGER NOT NULL,
	PRIMARY KEY("PointID" AUTOINCREMENT),
	FOREIGN KEY("RunID") REFERENCES "TestRuns"("RunID")
);
CREATE TABLE IF NOT EXISTS "Sensors" (
	"SensorID"	INTEGER,
	"ModelNumber"	TEXT NOT NULL,
	"SerialNumber"	TEXT NOT NULL UNIQUE,
	"SensorType"	TEXT NOT NULL,
	PRIMARY KEY("SensorID" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "TestConfigurations" (
	"ConfigID"	INTEGER,
	"SensorModel"	TEXT NOT NULL,
	"TargetSampleRateHz"	REAL NOT NULL,
	"SteadyStateDurationSec"	INTEGER NOT NULL,
	"AllowedTolerancePercent"	REAL NOT NULL,
	"CreatedDate"	TEXT NOT NULL,
	PRIMARY KEY("ConfigID" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "TestRuns" (
	"RunID"	INTEGER,
	"SensorID"	INTEGER NOT NULL,
	"ConfigID"	INTEGER NOT NULL,
	"Timestamp"	TEXT NOT NULL,
	"OverallPassFail"	INTEGER NOT NULL,
	"TDMSFilePath"	TEXT,
	PRIMARY KEY("RunID" AUTOINCREMENT),
	FOREIGN KEY("ConfigID") REFERENCES "TestConfigurations"("ConfigID"),
	FOREIGN KEY("SensorID") REFERENCES "Sensors"("SensorID")
);
COMMIT;
