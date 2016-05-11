ALTER TABLE message ADD COLUMN dismiss_button_ui_flags INTEGER NOT NULL DEFAULT 0;
ALTER TABLE button ADD COLUMN ui_flags INTEGER NOT NULL DEFAULT 0;

INSERT INTO configurationprovider (category, valuetype, key, value)
    VALUES ('', 'S', 'geoLocationTrackingFromTimeSeconds', '0');

INSERT INTO configurationprovider (category, valuetype, key, value)
    VALUES ('', 'S', 'geoLocationTrackingTillTimeSeconds', '86399');

INSERT INTO configurationprovider (category, valuetype, key, value)
    VALUES ('', 'S', 'geoLocationTrackingDays', '127');

INSERT INTO configurationprovider (category, valuetype, key, value)
    VALUES ('', 'S', 'useGPSWhileOnBattery', '0');

INSERT INTO configurationprovider (category, valuetype, key, value)
    VALUES ('', 'S', 'useGPSWhileCharging', '1');

INSERT INTO configurationprovider (category, valuetype, key, value)
    VALUES ('', 'S', 'settingsVersion', '0');