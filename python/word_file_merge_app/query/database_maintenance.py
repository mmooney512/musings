# /query / database_maintenance.py

class QueryDatabaseMaintenance():
    # version
    CLEAR_ALL ="""
        DELETE FROM generated;
        DELETE FROM replacement;
        DELETE FROM placeholder;
        DELETE FROM template;
        VACUUM;
        ;
        """
    
    CREATE_TABLE_TEMPLATE = """
    CREATE TABLE "template" (
        "template_id"	INTEGER,
        "template_name"	VARCHAR(512) NOT NULL,
        "template_file"	BLOB NOT NULL,
        "deleted"	INTEGER NOT NULL DEFAULT 0,
        "modify_at"	TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
        PRIMARY KEY("template_id" AUTOINCREMENT)
    )"""
    CREATE_TABLE_PLACEHOLDER = """
    CREATE TABLE "placeholder" (
        "placeholder_id"	INTEGER,
        "template_id"	INTEGER NOT NULL COLLATE BINARY,
        "placeholder_type"	varchar(16) NOT NULL DEFAULT 'inline',
        "placeholder_name"	varchar(128) NOT NULL,
        "placeholder_order"	INTEGER NOT NULL,
        "deleted"	INTEGER NOT NULL DEFAULT 0,
        "modify_at"	TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
        PRIMARY KEY("placeholder_id" AUTOINCREMENT),
        FOREIGN KEY("template_id") REFERENCES "template"("template_id") ON DELETE CASCADE,
        CHECK("placeholder_type" IN ('inline', 'list', 'bullet','static'))
    )"""

    CREATE_TABLE_REPLACEMENT = """
    CREATE TABLE "replacement" (
        "replacement_id"	INTEGER,
        "template_id"	INTEGER NOT NULL,
        "placeholder_id"	INTEGER NOT NULL,
        "replacement_group"	varchar(512) NOT NULL,
        "replacement_value"	TEXT NOT NULL,
        "deleted"	INTEGER NOT NULL DEFAULT 0,
        "modify_at"	TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
        PRIMARY KEY("replacement_id" AUTOINCREMENT),
        FOREIGN KEY("placeholder_id") REFERENCES "placeholder"("placeholder_id") ON DELETE CASCADE,
        FOREIGN KEY("template_id") REFERENCES "template"("template_id") ON DELETE CASCADE
    )"""

    CREATE_TABLE_GENERATED = """
    CREATE TABLE "generated" (
        "generated_id" INTEGER,
        "template_id"	INTEGER NOT NULL,
        "generated_file_name" VARCHAR(128) NOT NULL,
        "generated_file_type" VARCHAR(128) NOT NULL,
        "generated_file"	BLOB NOT NULL,
        "deleted"	INTEGER NOT NULL DEFAULT 0,
        "modify_at"	TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
        PRIMARY KEY("generated_id" AUTOINCREMENT)
    )"""


