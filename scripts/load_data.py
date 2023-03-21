import sqlite3
import os
import xml.etree.cElementTree as etree
import logging

ANATHOMY = {
    'postlinks': {
        'Id':'INTEGER',
        'CreationDate':'DATETIME',
        'PostId':'INTEGER',
        'RelatedPostId':'INTEGER',
        'LinkTypeId':'INTEGER',
    },
    'posts': {
        'Id':'INTEGER', 
        'PostTypeId':'INTEGER', 
        'AcceptedAnswerId':'INTEGER', 
        'ParentID':'INTEGER', 
        'CreationDate':'DATETIME',
        'DeletionDate':'DATETIME',
        'Score':'INTEGER',
        'ViewCount':'INTEGER',
        'Body':'TEXT',
        'OwnerUserId':'INTEGER', 
        'OwnerDisplayName':'TEXT', 
        'LastEditorUserId':'INTEGER',
        'LastEditorDisplayName':'TEXT', 
        'LastEditDate':'DATETIME',
        'LastActivityDate':'DATETIME',
        'CommunityOwnedDate':'DATETIME',
        'Title':'TEXT',
        'Tags':'TEXT',
        'AnswerCount':'INTEGER',
        'CommentCount':'INTEGER',
        'FavoriteCount':'INTEGER',
        'ClosedDate':'DATETIME',
    },
}

def dump_files(file_names, anathomy, 
                dump_path='../data/', 
                dump_database_name = 'so-dump.db',
                create_query='CREATE TABLE IF NOT EXISTS [{table}]({fields})',
                insert_query='INSERT INTO {table} ({columns}) VALUES ({values})',
                log_filename='so-parser.log'):

    # logging.basicConfig(filename=os.path.join(dump_path, log_filename),level=logging.INFO)
    db = sqlite3.connect(os.path.join(dump_path, dump_database_name))

    for file in file_names:
        print("Opening {0}.xml".format(file))
        with open(os.path.join(dump_path, file + '.xml')) as xml_file:
            tree = etree.iterparse(xml_file)
            table_name = file

            sql_create = create_query.format(
                                table=table_name, 
                                fields=", ".join(['{0} {1}'.format(name, type) for name, type in anathomy[table_name].items()]))
            print('Creating table {0}'.format(table_name))

            try:
                # logging.info(sql_create)
                db.execute(sql_create)
            except Exception as e:
                # logging.warning(e)
                print("exception", e)

            for events, row in tree:
                try:
                    # logging.debug(row.attrib.keys())

                    db.execute(insert_query.format(
                                table=table_name, 
                                columns=', '.join(row.attrib.keys()), 
                                values=('?, ' * len(row.attrib.keys()))[:-2]),
                                row.attrib.values())

                except Exception as e:
                    # logging.warning(e)
                    print ("exception", e)
                finally:
                    row.clear()
            db.commit()
            del(tree)

if __name__ == '__main__':
    dump_files(ANATHOMY.keys(), ANATHOMY)