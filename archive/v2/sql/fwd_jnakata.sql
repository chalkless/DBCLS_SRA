ALTER TABLE exp_runWK RENAME TO exp_run;

ALTER TABLE exp_sample RENAME TO  exp_sampleBAK;
ALTER TABLE exp_sampleWK RENAME TO  exp_sample;

ALTER TABLE experiment2 RENAME TO experiment2BAK;
ALTER TABLE experiment2WK RENAME TO experiment2;

ALTER TABLE experiment3 RENAME TO experiment3BAK;
ALTER TABLE experiment3WK RENAME TO experiment3;

ALTER TABLE experiment RENAME TO experimentBAK;
ALTER TABLE experimentWK RENAME TO experiment;

ALTER TABLE sample RENAME TO sampleBAK;
ALTER TABLE sampleWK RENAME TO sample;

ALTER TABLE study RENAME TO studyBAK;
ALTER TABLE studyWK RENAME TO study;

ALTER TABLE study2 RENAME TO study2BAK;
ALTER TABLE study2WK RENAME TO study2;

ALTER TABLE study_exp RENAME TO study_expBAK;
ALTER TABLE study_expWK RENAME TO study_exp;

ALTER TABLE study_sample RENAME TO study_sampleBAK;
ALTER TABLE study_sampleWK RENAME TO study_sample;

ALTER TABLE study_type RENAME TO study_typeBAK;
ALTER TABLE study_typeWK RENAME TO study_type;

ALTER TABLE submission RENAME TO submissionBAK;
ALTER TABLE submissionWK RENAME submission;

ALTER TABLE sum_exp RENAME TO sum_expBAK;
ALTER TABLE sum_expWK RENAME TO sum_exp;

ALTER TABLE sum_run2 RENAME TO sum_run2BAK;
ALTER TABLE sum_run2WK RENAME TO sum_run2;

ALTER TABLE sum_run RENAME TO sum_runBAK;
ALTER TABLE sum_runWK RENAME TO sum_run;

ALTER TABLE taxid RENAME TO taxidBAK;
ALTER TABLE taxidWK RENAME TO taxid;

