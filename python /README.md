---
title: "Streamlit Table Editor App"
date: "2024-11-19"
categories: 
  - "streamlit"
  - "python"
  - "pandas"
  - "code"
tags: 
  - "streamlit"
  - "crud"
  - "tutorial"
  - "sql"
  - "python"
  - "website"
coverImage: "edit_row_crop_900_400.png"
---

CRUD (Create, Read, Update, and Delete) it is the cornerstone of working with database applications. Today I will walk through using the [Streamlit](https://streamlit.io/) python framework to build a web based app that you can use to interact with a database. The app will allow you to Read, Update, and Delete tables in your database.

The creators of [Streamlit](https://streamlit.io/) framework have taken care of a large amount of the burden of creating a web based app. However not all of the widgets are feature complete. Streamlit is an asynchronous framework allowing 100s or 1000s of users to use your app. With CRUD operations that is great for the Create and Read, but for Update and Delete, not so much.

Today's tutorial will show you how to overcome those limitations and hopefully inspire you on how you could use Streamlit for your own apps.

All of the code is available on my [Github page](https://github.com/mmooney512/musings/tree/main/python%20/streamlit%20table%20editor), please use responsibly.

**NOTE:** The code presented is not production ready; i.e. no [Exception](https://docs.python.org/3/library/exceptions.html) blocks but it wouldn't take much more effort to adapt the code to be production ready. Instead we will concentrate on the important parts and get you downloading files quickly. Let's start the tutorial below.

* * *

## Pages

1. [Main Page](#main-app)

3. [Files](https://eipsoftware.com/musings/streamlit-crud-app/?page=2#files)
    - [Directory Structure](https://eipsoftware.com/musings/streamlit-crud-app/?page=2#g3988f71708dd)
    
    - [main.py](https://eipsoftware.com/musings/streamlit-crud-app/?page=2#g51d2bbb785f7)
    
    - [home.py](https://eipsoftware.com/musings/streamlit-crud-app/?page=2#g37c8de04e1f1)
        1. [home.py - library import](https://eipsoftware.com/musings/streamlit-crud-app/?page=2#g27ce3bcf0c5a)
        
        3. [main.py - main()](https://eipsoftware.com/musings/streamlit-crud-app/?page=2#g72fdeccc4b44)

5. [pages](https://eipsoftware.com/musings/streamlit-crud-app/?page=3#g51ee7095275e)
    - [pages - add\_row.py](https://eipsoftware.com/musings/streamlit-crud-app/?page=3#g1c3875d3e2f9)
    
    - [pages - edit\_row.py](https://eipsoftware.com/musings/streamlit-crud-app/?page=3#gbf2e49ba488d)
    
    - [Pages - delete\_row.py](https://eipsoftware.com/musings/streamlit-crud-app/?page=3#g7c8cfb960e22)

7. [Streamlit Handler Class](https://eipsoftware.com/musings/streamlit-crud-app/?page=4#g76ff6c324690)
    - [StreamlitHandler - Base](https://eipsoftware.com/musings/streamlit-crud-app/?page=4#g1fb652c376af)
    
    - [StreamlitAddData](https://eipsoftware.com/musings/streamlit-crud-app/?page=4#ge5ab805fe105)
    
    - [StreamlitEditData](https://eipsoftware.com/musings/streamlit-crud-app/?page=4#streamliteditdata)
    
    - [StreamlitDeleteData](https://eipsoftware.com/musings/streamlit-crud-app/?page=4#streamliteditdata)

9. [Data Handler Class](https://eipsoftware.com/musings/streamlit-crud-app/?page=5#data-handler-class)

11. [PandasSqlHandler](https://eipsoftware.com/musings/streamlit-crud-app/?page=6#pandassqlhandler)

13. [Configuration Files](https://eipsoftware.com/musings/streamlit-crud-app/?page=7#configuration-files)
    - [sql\_config.yaml](https://eipsoftware.com/musings/streamlit-crud-app/?page=7#sql-config-yaml)
    
    - [streamlit\_config.yaml](https://eipsoftware.com/musings/streamlit-crud-app/?page=7#streamlit-config-yaml)
    
    - [sql\_column\_config.yaml](https://eipsoftware.com/musings/streamlit-crud-app/?page=7#sql-column-config-yaml)

15. [Query](https://eipsoftware.com/musings/streamlit-crud-app/?page=7#query)
    1. [info.columns](https://eipsoftware.com/musings/streamlit-crud-app/?page=7#info-columns)
    
    3. [sys.row\_count](https://eipsoftware.com/musings/streamlit-crud-app/?page=7#sys-row-count)
    
    5. [Table Query - Example](https://eipsoftware.com/musings/streamlit-crud-app/?page=7#table-query-example)

17. [Github Files](https://eipsoftware.com/musings/streamlit-crud-app/?page=8#github-files)

* * *

## Files

1. [Files](https://eipsoftware.com/musings/streamlit-crud-app/?page=2#files)
2. [Directory Structure](https://eipsoftware.com/musings/streamlit-crud-app/?page=2#g3988f71708dd)
3. [main.py](https://eipsoftware.com/musings/streamlit-crud-app/?page=2#g51d2bbb785f7)
4. [home.py](https://eipsoftware.com/musings/streamlit-crud-app/?page=2#g37c8de04e1f1)
    1. [home.py - library import](https://eipsoftware.com/musings/streamlit-crud-app/?page=2#g27ce3bcf0c5a)
    2. [main.py - main()](https://eipsoftware.com/musings/streamlit-crud-app/?page=2#g72fdeccc4b44)

## Directory Structure

![](images/dir_structure.png)

## main.py

```
import os

if __name__ == "__main__":
    os.system("streamlit run home.py")
```

Is that it? Yes.

We will use main.py to start the Streamlit app, passing in the python file name we want to use for the home page. In this case, home.py. Speaking of home.py, let's look at it next.

## home.py

```
# home.py

# -- LIBRARY -----------------------------------------------------------------
import streamlit as st
import pandas as pd
import yaml
import os

# -- LOCAL -------------------------------------------------------------------
from library.pandas_sql_handler import PandasSqlHandler
from data_handler.data_handler import DataHandler
from config import sql_column_config


def main():
    st.set_page_config(layout="wide")
    st.title("Database Table Editor")

    st.markdown(
        """
        Select Action and Table to Edit from menu
        """
        )


if __name__ == "__main__":
    main()
```

Hmmm... this is not looking too complicated. And you would be correct.

Many folks will name the home page file, app.py. I deviated a little bit from convention here, in order to help keep track of what is going. on.

Now let's go line by line

* * *

### home.py - library import

```
# home.py

# -- LIBRARY -----------------------------------------------------------------
import streamlit as st
import pandas as pd
import yaml
import os
```

We import some standard libraries that are used in the python world, [pandas](https://pandas.pydata.org/), [yaml](https://pypi.org/project/PyYAML/), os, and of course [streamlit](https://streamlit.io/). The appendix will contain details on how to install the packages.

Next we will import some local files that we will create below.

```
# -- LOCAL -------------------------------------------------------------------
from library.pandas_sql_handler import PandasSqlHandler
from data_handler.data_handler import DataHandler
from config import sql_column_config
```

[PandasSQLHandler](#pandassqlhandler)

[DataHandler](#data-handler-class)

[sql\_column\_config](#sql-column-config-yaml)

* * *

### main.py - main()

We aliased the streamlit package as st, which is pretty common alias for the package.

```
    st.set_page_config(layout="wide")
    st.title("Database Table Editor")

    st.markdown(
        """
        Select Action and Table to Edit from menu
        """
        )

```

In the main function, we will call three streamlit methods.

```
    st.set_page_config(layout="wide")
```

By default streamlit will limit the width of the content on the webpage. For our tutorial, I will set the layout to wide, to allow for using the complete width of the browser window.

```
    st.title("Database Table Editor")
```

Next we will add a title for the page. By default it is size of H1 html tag.

```
   st.markdown(
        """
        Select Action and Table to Edit from menu
        """
        )
```

The last bit is to add some text, supporting markdown. You could also use some the st.text method to accomplish the same thing.

If you were to run the app you would see the following, without the menu on the sidebar, we will get to that part in a moment.

![](images/dte_home.png)

* * *

## pages

Streamlit has an automatic method of adding pages to the sidebar menu. From the top menu, we create a directory named, pages.

The pages will be listed sorted by a leading number. In our example we will name the files, 1\_add\_row.py, 2\_edit\_row.py, 3\_delete\_row.py. Streamlit will remove the number from the file name and convert underscores to spacees.

![](images/dte_pages.png)

* * *

1. [pages](https://eipsoftware.com/musings/streamlit-crud-app/?page=3#g51ee7095275e)
    1. [Pages - add\_row.py](https://eipsoftware.com/musings/streamlit-crud-app/?page=3#g1c3875d3e2f9)
        1. [Pages - add\_row.py - main()](https://eipsoftware.com/musings/streamlit-crud-app/?page=3#gb45116603225)
            1. [pages - add\_row.py - main() - session\_state](https://eipsoftware.com/musings/streamlit-crud-app/?page=3#gd1872553618f)
            2. [pages - add\_row.py - main() - select table](https://eipsoftware.com/musings/streamlit-crud-app/?page=3#gdccb25457894)
            3. [pages - add\_row.py - main() - data\_editor](https://eipsoftware.com/musings/streamlit-crud-app/?page=3#g6d46cc4c17b6)
    2. [pages - edit\_row.py](https://eipsoftware.com/musings/streamlit-crud-app/?page=3#gbf2e49ba488d)
        1. [pages - edit\_row.py - main()](https://eipsoftware.com/musings/streamlit-crud-app/?page=3#g1703f2ee0804)
            1. [pages - edit\_row.py - main() - session\_state](https://eipsoftware.com/musings/streamlit-crud-app/?page=3#g19584fa9555b)
            2. [pages - edit\_row.py - main() - sidebar](https://eipsoftware.com/musings/streamlit-crud-app/?page=3#g5fc24657cc68)
            3. [pages - edit\_row.py - main() - data\_editor](https://eipsoftware.com/musings/streamlit-crud-app/?page=3#gd10215f36ead)
    3. [Pages - delete\_row.py](https://eipsoftware.com/musings/streamlit-crud-app/?page=3#g7c8cfb960e22)
        1. [pages – delete\_row.py – main()](https://eipsoftware.com/musings/streamlit-crud-app/?page=3#g7d90d7c2ade7)
            1. [pages - delete\_row.py - main() - session state](https://eipsoftware.com/musings/streamlit-crud-app/?page=3#g70f51824f452)
            2. [pages - delete\_row.py - main() - table select box](https://eipsoftware.com/musings/streamlit-crud-app/?page=3#g8533b3b5af7d)
            3. [pages - delete\_row.py - main() - sidebar](https://eipsoftware.com/musings/streamlit-crud-app/?page=3#gd6ed28498098)
            4. [pages - delete\_row.py - main() - data\_editor](https://eipsoftware.com/musings/streamlit-crud-app/?page=3#geb1797ec2efa)

* * *

### Pages - add\_row.py

![](images/add_row-1024x468.png)

The add\_row.py file will allow the user to add a row to the database. We will use the tables column names and data types when creating the streamlit data editor widget.

* * *

#### Pages - add\_row.py - main()

```
# pages / 1_add_row.py

# -- LIBRARY -----------------------------------------------------------------
import streamlit as st

# -- LOCAL -------------------------------------------------------------------
from streamlit_handler import StreamlitAddData

def main():
    st.set_page_config(layout="wide")
    # INIT
    if 'data_editor_add' not in st.session_state:
        st_handler = StreamlitAddData()
        st.session_state['st_handler'] = st_handler
    else:
        st_handler = st.session_state['st_handler'] 

    # layout
    st.header("Add a New Row")
    
    # select box UI for which table
    selected_table = st_handler.selectbox_table()

    if selected_table is not None:
        # set the name of the table will be adding rows too
        st_handler.source_table_name = selected_table
        # display the data_editor on screen
        new_data = st_handler.fetch_empty_table()

        if st.button(label="Add Row", 
                     key="btn_add_row"):
            st_handler.add_source_data(new_data=new_data)
            if st_handler.query_success():
                st.success("New rows added to the database")


if __name__ == "__main__":
    main()

```

Details about the code.

Here we are doing a similar thing as the home page. However I have created a class called streamlit\_handler with a subclass of StreamlitAddData that will help with passing of the data from the database to the streamlit widgets.

We will review the streamlit\_handler later in the tutorial.

* * *

##### pages - add\_row.py - main() - session\_state

One of the main issues with how the streamlit package works is that by default it is stateless, unless you use the streamlit session\_state method.

```
def main():
    st.set_page_config(layout="wide")
    # INIT
    if 'data_editor_add' not in st.session_state:
        st_handler = StreamlitAddData()
        st.session_state['st_handler'] = st_handler
    else:
        st_handler = st.session_state['st_handler'] 

```

Here we are checking if the session state has been set. If the session is set, we will re-invoking the session state. The st\_handler object contains all of the data we need to add a row to the table.

* * *

##### pages - add\_row.py - main() - select table

```
    # layout
    st.header("Add a New Row")
    
    # select box UI for which table
    selected_table = st_handler.selectbox_table()
```

We will add a select box so the user can choose which table they would like to add a row too.

* * *

##### pages - add\_row.py - main() - data\_editor

```
    if selected_table is not None:
        # set the name of the table will be adding rows too
        st_handler.source_table_name = selected_table
        # display the data_editor on screen
        new_data = st_handler.fetch_empty_table()
```

Here, we will wait until the user has selected a table from the select box. On the change event, the main() function will first fetch the table name from the select box. Second, using the st\_handler method fetch\_empty\_table() will read the meta data about the selected table and populate the data\_editor widget.

**pages - add\_row.py - main() - add\_row button**

```
        if st.button(label="Add Row", 
                     key="btn_add_row"):
            st_handler.add_source_data(new_data=new_data)
```

Now we will wait until the user presses the button labeled "Add Row" and will then invoke the add\_source\_data method, to write the data to the table.

**pages - edit\_row.py - main() - success div**

```
            if st_handler.query_success():
                st.success("New rows added to the database")
```

If the add\_source\_data method is successful, the query\_success property will return True; and will display a message to the user.

* * *

### pages - edit\_row.py

![](images/edit_row-1024x604.png)

The edit\_row.py page follows a similar pattern as the add\_row.py page with a few additions. We will add page navigation buttons and controls for pagination of the table data, let's dig in.

* * *

#### pages - edit\_row.py - main()

```
# pages / 2_edit_row.py

# -- LIBRARY -----------------------------------------------------------------
import streamlit as st

# -- LOCAL -------------------------------------------------------------------
from streamlit_handler import StreamlitEditData

def main():
    st.set_page_config(layout="wide",
                       page_icon=":anchor:"
                       )

    if 'data_editor_update' not in st.session_state:
        st_handler = StreamlitEditData()
        st.session_state['st_handler'] = st_handler
    else:
        st_handler = st.session_state['st_handler'] 

    st.title("Edit Rows") 

    # select box UI for which table
    selected_table = st_handler.selectbox_table()
    
    if selected_table is not None:
        # set the name of the table will be adding rows too
        st_handler.source_table_name = selected_table
        st_handler.total_pages = st_handler.fetch_row_count()

 
        with st.sidebar:
            # Dropdown to select rows per page
            st_handler.selectbox_rows_per_page()
            
            # input box to select page number
            st_handler.input_page_select()

        # page nav controls
        st_handler.page_nav_controls()

        with st.container(border=True):
            edited_data = st_handler.data_editor_formatted()

        st.button(label="Update Rows",
                  key="btn_update_rows",
                  on_click=st_handler.update_source_data,
                  args=(edited_data,)
                  )
        if st_handler.query_success():
            st.success("Updateds saved to the database.")

if __name__ == "__main__":
    main()    
```

Details about the code, similar to the add\_row.py, we will use check if the session state has been set. If the session is set, we will re-invoking the session state. The st\_handler object contains all of the data we need to edit a row in the table.

Next there are four parts to the page, checking session\_state, the table selectbox, the sidebar, and the data\_editor widget.

* * *

##### pages - edit\_row.py - main() - session\_state

```
def main():
    st.set_page_config(layout="wide",
                       page_icon=":anchor:"
                       )

    if 'data_editor_update' not in st.session_state:
        st_handler = StreamlitEditData()
        st.session_state['st_handler'] = st_handler
    else:
        st_handler = st.session_state['st_handler'] 
```

If the session is set, we will re-invoking the session state. The st\_handler object contains all of the data we need to edit a row in the table.

* * *

##### pages - edit\_row.py - main() - sidebar

```
        with st.sidebar:
            # Dropdown to select rows per page
            st_handler.selectbox_rows_per_page()
            
            # input box to select page number
            st_handler.input_page_select()
```

Streamlit automatically adds a link for every .py file in the pages directory. In addition, we will add two widgets below the page links in the sidebar.

**pages - edit\_row.py - main() - nav controls**

```
        # page nav controls
        st_handler.page_nav_controls()
```

After the side bar, we will call the st\_handler.page\_nav\_controls() method to print a row with multiple columns showing the page controls.

* * *

##### pages - edit\_row.py - main() - data\_editor

```
        with st.container(border=True):
            edited_data = st_handler.data_editor_formatted()
```

Below the page nav controls we will display the data\_editor widget called by the st\_handler.data\_editor\_formatted() method.

**pages - edit\_row.py - main() - update rows button**

```
        st.button(label="Update Rows",
                  key="btn_update_rows",
                  on_click=st_handler.update_source_data,
                  args=(edited_data,)
                  )
```

Next, we will display a button for when the user has completed their edits. The on\_click argument specifies the function to call after the user clicks the button. Some Streamlit widgets support on\_click and others on\_change. In our case we will call the st\_handler.update\_source\_data method.

**Pages - edit\_row.py - main() - success div**

```
        if st_handler.query_success():
            st.success("Updateds saved to the database.")
```

If the update\_source\_data method is successful, the query\_success property will return True; and will display a message to the user.

* * *

### Pages - delete\_row.py

![](images/delete_row-1024x594.png)

The delete\_row.py page follows a similar pattern as the edit\_row.py page with a few additions. We will add a column named Select to the dataset, allowing user to check which rows to delete. After pressing the Delete Rows button we will show a confirmation button to the user, let’s get started.

* * *

#### pages – delete\_row.py – main()

```
# pages / 3_delete_row.py

# -- LIBRARY -----------------------------------------------------------------
import streamlit as st

# -- LOCAL -------------------------------------------------------------------
from streamlit_handler import StreamlitDeleteData

def main():
    st.set_page_config(layout="wide")
    # INIT
    if 'data_editor_delete' not in st.session_state:
        st_handler = StreamlitDeleteData()
        st.session_state['st_handler'] = st_handler
    else:
        st_handler = st.session_state['st_handler']     

    # layout
    st.header("Delete Rows")
    
    # select box UI for which table
    selected_table = st_handler.selectbox_table()

    if selected_table is not None:
        # Tell user what to do
        st.text("Check box in Select column to mark row for deletion")
        st_handler.source_table_name = selected_table
        st_handler.total_pages = st_handler.fetch_row_count()

        with st.sidebar:
            # Dropdown to select rows per page
            st_handler.selectbox_rows_per_page()
            
            # input box to select page number
            st_handler.input_page_select()

        # page nav controls
        st_handler.page_nav_controls()

        # source table data
        table_data = st_handler.data_editor_formatted()

        # delete the data from the table
        st.button(label="Delete Rows",
                  key="btn_delete_rows",
                  on_click=st_handler.prompt_for_confirmation,
                  args=(table_data.query("Select == True").shape[0],)
                  )
        
        #if st.session_state['deletion_requested']:
        if st_handler.deletion_requested:
            # delete the data from the table
            st.button(label="Confirm Deletion",
                    key="btn_confirm_delete",
                    on_click=st_handler.delete_source_data,
                    args=(table_data.query("Select == True"),))
        
        if st_handler.query_success():
            # let user know rows have been deleted
            st.success("Selected rows deleted successfully.")
            table_data['Select'] = False

        st.session_state['st_handler'] = st_handler


if __name__ == "__main__":
    main()
```

Details about the code, similar to the edit\_row.py, we will use check if the session state has been set. If the session is set, we will re-invoking the session state. The st\_handler object contains all of the data we need to select which rows in the table to delete.

Next there are five parts to the page, checking session\_state, the table selectbox, the sidebar, the data\_editor widget, and confirmation from the user.

* * *

##### pages - delete\_row.py - main() - session state

```
def main():
    st.set_page_config(layout="wide")
    # INIT
    if 'data_editor_delete' not in st.session_state:
        st_handler = StreamlitDeleteData()
        st.session_state['st_handler'] = st_handler
    else:
        st_handler = st.session_state['st_handler']     
```

If the session is set, we will re-invoking the session state. The st\_handler object contains all of the data we need to delete a row in the table.

* * *

##### pages - delete\_row.py - main() - table select box

```
    # layout
    st.header("Delete Rows")
    
    # select box UI for which table
    selected_table = st_handler.selectbox_table()

```

Add a header for the page, and then call the st\_handler selectbox\_table method, same as in addrow and edit\_row pages.

* * *

##### pages - delete\_row.py - main() - sidebar

```
        with st.sidebar:
            # Dropdown to select rows per page
            st_handler.selectbox_rows_per_page()
            
            # input box to select page number
            st_handler.input_page_select()
```

Streamlit automatically adds a link for every .py file in the pages directory. In addition, we will add two widgets below the page links in the sidebar.

**pages – delete\_row.py – main() – nav controls**

```
        # page nav controls
        st_handler.page_nav_controls()
```

After the side bar, we will call the st\_handler.page\_nav\_controls() method to print a row with multiple columns showing the page controls.

* * *

##### pages - delete\_row.py - main() - data\_editor

```
        # source table data
        table_data = st_handler.data_editor_formatted()
```

Below the page nav controls we will display the data\_editor widget called by the st\_handler.data\_editor\_formatted() method. The method is called from the subclass. The method will add a column named Select which is Boolean data type, and shown as a checkbox in thee data\_editor widget.

**pages – delete\_row.py – main() – delete rows button**

```
        # delete the data from the table
        st.button(label="Delete Rows",
                  key="btn_delete_rows",
                  on_click=st_handler.prompt_for_confirmation,
                  args=(table_data.query("Select == True").shape[0],)
                  )
```

Next, we will display a button for when the user has completed which rows they want to delete. The on\_click argument specifies the function to call after the user clicks the button. Some Streamlit widgets support on\_click and others on\_change. In our case we will call the st\_handler.prompt\_for\_confirmation method.

* * *

**pages - delete\_row.py - main() - confirmation**

```
        if st_handler.deletion_requested:
            # delete the data from the table
            st.button(label="Confirm Deletion",
                    key="btn_confirm_delete",
                    on_click=st_handler.delete_source_data,
                    args=(table_data.query("Select == True"),))
```

When the user selects they want to delete row(s) from the table, a confirmation button will be displayed. After clicking the confirmation button the st\_handler.delete\_source\_data method will be called.

**pages – delete\_row.py – main()  – success div**

```
        if st_handler.query_success():
            # let user know rows have been deleted
            st.success("Selected rows deleted successfully.")
            table_data['Select'] = False
```

If the delete\_source\_data method is successful, the query\_success property will return True; and will display a message to the user.

Now, that we have reviewed the pages, on the next page we will dive into the StreamlitHandler Class and how it communicates with the Streamlit widgets and the database.

## Streamlit Handler Class

The class is to help with creating the Streamlit widgets and communication between the widgets and the databasee.

Three classes inherit from the StreamlitHandler class

- StreamlitAddData

- StreamlitEditData

- StreamlitDeleteData

The three classes as you can guess relates to the app's corresponding page.

1. [Streamlit Handler Class](https://eipsoftware.com/musings/streamlit-crud-app/?page=4#g76ff6c324690)
    1. [StreamlitHandler - Base](https://eipsoftware.com/musings/streamlit-crud-app/?page=4#g1fb652c376af)
        1. [Methods](https://eipsoftware.com/musings/streamlit-crud-app/?page=4#g26e160140609)
            1. [\_load\_query](https://eipsoftware.com/musings/streamlit-crud-app/?page=4#slh-load-query)
            2. [\_\_set\_primary\_key\_column\_name](https://eipsoftware.com/musings/streamlit-crud-app/?page=4#slh-set-primary-key-column-name)
            3. [\_\_set\_column\_order](https://eipsoftware.com/musings/streamlit-crud-app/?page=4#slh-set-column-order)
            4. [fetch\_row\_count](https://eipsoftware.com/musings/streamlit-crud-app/?page=4#fetch-row-count)
            5. [fetch\_table\_data](https://eipsoftware.com/musings/streamlit-crud-app/?page=4#fetch-table-data)
            6. [jump\_current\_page](https://eipsoftware.com/musings/streamlit-crud-app/?page=4#jump-current-page)
            7. [move\_current\_page](https://eipsoftware.com/musings/streamlit-crud-app/?page=4#move_current_page)
            8. [input\_page\_select](https://eipsoftware.com/musings/streamlit-crud-app/?page=4#input_page_select)
            9. [page\_nav\_controls](https://eipsoftware.com/musings/streamlit-crud-app/?page=4#page-nav-controls)
            10. [selectbox\_rows\_per\_page](https://eipsoftware.com/musings/streamlit-crud-app/?page=4#selectbox-rows-per-page)
            11. [selectbox\_table](https://eipsoftware.com/musings/streamlit-crud-app/?page=4#selectbox-table)
            12. [query\_success](https://eipsoftware.com/musings/streamlit-crud-app/?page=4#query-success)
            13. [update\_rows\_per\_page](https://eipsoftware.com/musings/streamlit-crud-app/?page=4#update-rows-per-page)
    2. [StreamlitAddData](https://eipsoftware.com/musings/streamlit-crud-app/?page=4#ge5ab805fe105)
        1. [Methods](https://eipsoftware.com/musings/streamlit-crud-app/?page=4#gf97c6fc85f8f)
            1. [fetch\_empty\_table](https://eipsoftware.com/musings/streamlit-crud-app/?page=4#ga875b89b4a99)
            2. [add\_source\_data](https://eipsoftware.com/musings/streamlit-crud-app/?page=4#g6fe09859ca7e)
    3. [StreamlitEditData](https://eipsoftware.com/musings/streamlit-crud-app/?page=4#streamliteditdata)
        1. [Methods](https://eipsoftware.com/musings/streamlit-crud-app/?page=4#methods)
            1. [data\_editor\_formatted](https://eipsoftware.com/musings/streamlit-crud-app/?page=4#data-editor-formatted)
            2. [update\_source\_data](https://eipsoftware.com/musings/streamlit-crud-app/?page=4#update-source-data)
    4. [StreamlitDeleteData](https://eipsoftware.com/musings/streamlit-crud-app/?page=4#streamliteditdata)
        1. [Methods](https://eipsoftware.com/musings/streamlit-crud-app/?page=4#methods)
            1. [data\_editor\_formatted](https://eipsoftware.com/musings/streamlit-crud-app/?page=4#data-editor-formatted)
            2. [prompt\_for\_confirmation](https://eipsoftware.com/musings/streamlit-crud-app/?page=4#prompt-for-confirmation)

### StreamlitHandler - Base

I won't go through all of the attributes, most are self explaintory. However, the one thing to mention is that the class uses two other classes, the PandasSQLHandler and the DataHandler class. We will discuss those classes further on in the tutorial.

#### Methods

##### \_load\_query

```
    def _load_query(self, query_file_name:str = None):
        """
        Read the query file stored in /query directory
        Name of file needs to match the table name which is displayed 
        in the drop down box

        Parameters
        ----------
        query_file_name : str, optional
            name of query file to be loaded in the class if the query name is
            not specified, it is assumed to use a file name of 
            schema.table_name.sql which is assigned in the source_table_name 
            property.
        """
        # if user supplied query_file_name else default val from class
        query_file_name = query_file_name if query_file_name is not None else self._query_file_name

        with open(f"query/{query_file_name}", 'r') as file:
            self.query = file.read()
```

Read the query file stored in /query directory. Name of file needs to match the table name which is displayed in the drop down box. The names of the tables to be displayed are configured in the config / sql\_column\_config.yaml file.

##### \_\_set\_primary\_key\_column\_name

```
    def __set_primary_key_column_name(self) -> None:
        """
        sets the primary key column name defined in the
        config/sql_column_config.yaml file
        """
        self.primary_key_column_name = sql_column_config.table[self._base_table_name].PRIMARY_KEY

```

sets the primary key column name defined in the config/sql\_column\_config.yaml file.

##### \_\_set\_column\_order

```
    def __set_column_order(self) -> None:
        """
        sets the column order for the data_editor widgets, while excluding
        the primary key column.
        values are defined in the config/sql_column_config.yaml file
        """

        table_columns = list(self.table_data.columns)
        if self.primary_key_column_name in table_columns:
            table_columns.remove(self.primary_key_column_name)
        self._column_order = tuple(table_columns)    
```

sets the column order for the data\_editor widgets, while excluding the primary key column. The values and order are defined in the config/sql\_column\_config.yaml file. The data\_editor widgets will display the columns in the same order as defined in the configuration file.

##### fetch\_row\_count

```
    def fetch_row_count(self) -> int:
        """
        Fetch number of rows in the table, used in pagination

        Returns
        -------
        int

        """
        # load the query string
        self._load_query(sql_column_config.info.count.QUERY)
        
        # fetch the row_count data
        data = self.db_handler.read_table(query=self.query,
                                          params=(self.source_table_name,)
                                          )                
        return data.loc[0, 'row_count']
```

Fetch number of rows in the table, used in pagination.

Will run a quick query, The query to use is defined in the config/sql\_column\_config.yaml file. In our tutorial we are connecting to Microsoft SQL database. Instead of doing a row\_count query which mayy be expensive, will read from the sys.dm\_db\_partition\_stats table which doesn't require elevated privileges. If the user has access to read / write to tables they should be able to read from sys.dm\_db\_partition\_stats.

##### fetch\_table\_data

```
    def fetch_table_data(self,row_params:tuple=None) -> None:
        """Loads the data from source table

        Returns
        -------
        None
        """
        self.__set_primary_key_column_name()
        self._load_query()
        
        self.table_data = self.db_handler.read_table(self.query, row_params)
        
        # set the column order, hiding the primary key column
        self.__set_column_order()
```

Method will query the database, using the PandasSQLHandler class. Storing the results to be sent to the data\_editor widget.

##### jump\_current\_page

```
    def jump_current_page(self)-> None:
        """
        When user increments, decrements, enters in page number
        move to that page
        """    
        page_input = st.session_state['current_page_input']
        
        if page_input >= 1 and page_input <= self._total_pages:
            self.current_page = page_input

        self.fetch_table_data(row_params=((self.current_page-1)*self.rows_per_page,
                                    self.rows_per_page,
                                    ))
```

Will query the source table, inclusive of prior database commits and based on user selected number of rows to display and total rows in the table will jump to the specified page. The requested page is read from Streamlist session\_state dictionary. Conditional logic is in place to prevent from requesting a page that doesn't exist.

##### move\_current\_page

```
    def move_current_page(self, action:str)-> None:
        """
        When user increments, decrements, enters in page number
        move to that page
        """        
        match action:
            case 'decrease':
                if self.current_page > 1:
                    self.current_page -= 1           
            case 'increase':
                if self.current_page < self._total_pages:
                    self.current_page += 1
            case _:
                self.current_page = 1

        self.fetch_table_data(row_params=((self.current_page-1)*self.rows_per_page,
                                    self.rows_per_page,
                                    )) 
```

Will query the source table, inclusive of prior database commits and based on user selected number of rows to display and total rows in the table will move back or forward one page. Using call backs from the nav control buttons, determines the user requested action. Conditional logic is in place to prevent from requesting a page that doesn't exist.

##### input\_page\_select

```
    def input_page_select(self):
        """
        Creates the streamlit input UI element, limiting to number of pages

        Returns
        -------
        streamlit.selectbox

        """
        # make sure we don't exceed max number of pages
        if self.current_page >= self.total_pages:
            self.current_page = int(self.total_pages)

        return(st.number_input(
                "Go to page",
                min_value=1,
                max_value=self.total_pages,
                value=self.current_page,
                step=1,
                key="current_page_input",
                on_change=self.jump_current_page,
            ))
```

Returns a Streamlit number\_input widget. The widget allows user to input which page number they want to jump too. The widget is used in the page navigation controls show in the sidebar.

##### page\_nav\_controls

```
    def page_nav_controls(self):
        """
        Creates the streamlit input UI elments for page navigation
        Returns
        -------
        streamlit.selectbox        
        """
        with st.container(key='page-controller', border=True):
            col1, col2, col3, col4, col5 = st.columns([1, 2, 1, 1, 4],
                                                vertical_alignment="bottom"
                                                )
        with col1:
            page_nav_label = st.markdown('<p style="font-size:1.3rem;">Page</p>', unsafe_allow_html=True)

        with col2:
            page_nav_page_info = st.markdown(f'<p style="font-size:1.3rem;">{self.current_page} of {self.total_pages}</p>', unsafe_allow_html=True)
            
        with col3:
            page_nav_prior_page = st.button(label="&lt;&lt;",
                 type="secondary", 
                 disabled=(self.current_page <= 1),
                 on_click=self.move_current_page,
                 args=('decrease',)
                 )
             
        with col4:
            page_nav_next_page = st.button(label="&gt;&gt;",
                 type="secondary", 
                 disabled=(self.current_page >= self.total_pages),
                 on_click=self.move_current_page,
                 args=('increase',)
                 )
        
        with col5:
            # intentionally left the column empty  
            page_nav_empty = st.empty()  # just a spacer column

        # return the page_nav controls
        return (page_nav_label, 
                page_nav_page_info, 
                page_nav_prior_page,
                page_nav_next_page,
                page_nav_empty
                )
```

The method will return five streamlit widgets that help the user navigate between pages in the data\_editor widget. I used st.markdown widget to pass the label and in the current page information. The other benefit is that you can pass css style properties. You do have to use the unsafe\_allow\_html property to True, for the Streamlit to apply the css style properties.

The buttons will navigate to prior page or next page, and use a call back to [move\_current\_page](#move_current_page) method.

##### selectbox\_rows\_per\_page

```
    def selectbox_rows_per_page(self):
        """
        Creates the streamlit drop down UI element, based on the table
        names stored in the /config/sql_column_config.yaml file

        Returns
        -------
        streamlit.selectbox

        """
        return (st.selectbox(label="Rows per Page:",
                             options=streamlit_config.selectbox.rows_per_page.OPTIONS,
                             index=0,
                             on_change=self.update_rows_per_page,
                             key="rows_per_page",
                             ))
```

Returns a select box that allows the user to determine how many rows to show in the data\_editor widgets. The values are defined in the config / streamlit\_config.yaml file.

##### selectbox\_table

```
    def selectbox_table(self):
        """
        Creates the streamlit drop down UI element, based on the table
        names stored in the /config/sql_column_config.yaml file

        Returns
        -------
        streamlit.selectbox

        """
        table_options = [f"{sql_column_config.table[tbl].SCHEMA}.{sql_column_config.table[tbl].NAME}" for tbl in sql_column_config.table]

        with st.container():
            col_left, col_mid, col_right = st.columns([4,4,4])
            with col_left:
                select_box_table = st.selectbox(label="Select a table to edit:",
                                                options=table_options,
                                                index=None,
                                                placeholder='Select a Table',                             
                                                )
            with col_mid:
                # intentionally left the column empty
                st.empty()
            with col_right:
                # intentionally left the column empty
                st.empty()

        return (select_box_table)
```

Returns a streamlit select\_box widget, listing the schema + table name to the user. The schema and table names are listed in the config / sql\_column\_config.yaml file. The select\_box widget is wrapped in a container allowing for formatting the width on the page. Default behavior is for the select\_box widget to use the full width of the page.

##### query\_success

```
    def query_success(self):
        """
        Returns
        -------
        boolean
            indicates if the last query run was completed successfully
        """
        return(self._query_success)
```

Returns a Boolean, indicates if the last query run was completed successfully.

##### update\_rows\_per\_page

```
    def update_rows_per_page(self) -> None:
        """
        Update number of rows per page to return
        """
        self.rows_per_page = st.session_state['rows_per_page']
```

Reads from the streamlit sesssion\_state dictionary, number of rows per page to return.

* * *

### StreamlitAddData

The class inherits from the StreamlitHandler class with additional methods for adding rows to the table.

#### Methods

##### fetch\_empty\_table

```
    def fetch_empty_table(self, table_name:str = None):
        """
        Create an empty data_editor widget with appropriate columns for
        user to input data to be inserted into the source table

        Parameters
        ----------
        table_name : str
            Name of source table

        Returns
        -------
        streamlit data_editor

        """
        query_params = (self._source_schema, self._base_table_name,)

        column_info = self.data_handler.get_table_columns(
            query=self.query,
            filter_columns=sql_column_config.table[self._base_table_name].COLUMNS,
            query_params=query_params
            )
        
        data = pd.DataFrame({column_name: pd.Series(dtype=column_type) for column_name, column_type in column_info.items()})
    
        return(st.data_editor(data=data,
                              num_rows="dynamic",
                              use_container_width=True
                              ))
```

Create the streamlit data\_editor widget. However we need to know which columns and their corresponding datatypes to add to the data\_editor widget. In order to do so wee will query the meta data of the table using the get\_table\_columns method from the data\_handler class. The method will also align the data types from Microsoft SQL to pandas dataframe datatypes. Additionally we will only show to the user, the columns specified in the config file, config / sql\_column\_config.yaml

##### add\_source\_data

```
    def add_source_data(self, new_data: pd.DataFrame):
        """
        Add new rows to the source

        Parameters
        ----------
        table_name : pandas DataFrame
            DataFrame will hold data to be inserted in to the source table
        """
        for row_ctr in range(0, new_data.shape[0]):
            self.data_handler.add_row(self.source_table_name,
                                      new_data.loc[[row_ctr]]
                                      )
        self._query_success = True
```

Now, we want to add the user input as a row to the table. The data will be passed from the data\_editor widget to thhe database using the data\_handler add\_row method. We loop through the data\_editor rows because the user may try adding multiple rows at the same time. If all of the rows are added successfully we set the \_query\_success flag to True. The flag is used by the [query\_success](#query-success) method.

* * *

### StreamlitEditData

The class inherits from the StreamlitHandler class with additional methods for editing rows in the table.

#### Methods

##### data\_editor\_formatted

```
    def data_editor_formatted(self):
        """
        Will return a formatted data_editor widget

        Returns
        -------
        streamlit data_editor widget

        """
        # offset = (current_page - 1) * rows per page
        # fetch next = rows per page
        self.fetch_table_data(row_params=((self.current_page-1)*self.rows_per_page,
                                          self.rows_per_page,
                                          ))

        return(st.data_editor(data=self.table_data, 
                              key="data_editor_update",
                              use_container_width=True,
                              column_order=self._column_order,
                              ))
```

Using the [fetch\_table\_data](#fetch-table-data) method will fetch the data from the source table. Will pass the offset and number of rows to return to the query to the row\_params parameter. The values have to be passed as a tuple.

Return the streamlit data\_editor widget to the user.

##### update\_source\_data

```
    def update_source_data(self, edited_data: pd.DataFrame)-> None:
        """
        Detect changes by comparing the original and edited DataFrames

        Parameters
        ----------
        edited_data : pandas DataFrame
            Will extract out the rows and columns that need to be updated
        """

        if not edited_data.equals(self.table_data):
            # get what has changed
            changes = edited_data.compare(self.table_data)
            for index, row in changes.iterrows():
                # Update only the changed columns for each modified row
                row_id = self.table_data.loc[index, self.primary_key_column_name]
                changed_columns = row.index.get_level_values(0).unique()
                
                # Extract only the changed values to update in the database
                update_data = edited_data.loc[index, changed_columns].to_dict()
                self.data_handler.update_row(table=self._remote_table_name, 
                                             update_data=update_data,
                                             primary_key_column=self.primary_key_column_name, 
                                             row_id=row_id)
            self._query_success = True
```

First we do a comparison to the source data and the data\_editor widget data. Both sets are data are stored in a Pandas data frame allowing us to quickly check if they are equal.

If they are not equal, we grab the changes by using the data frame .compare method.

Next we loop through the rows and columns to determine what has changed. We only want to update the column data that has changed. We store the changes in the update\_data in a dictionary variable.

Lastly we call the data\_handler update\_row method to update the source table. The method allows for sending multiple row updates. However each row that has changed will create an UPDATE sql statement to be executed.

Lastly if all the updates have been process the we set the \_query\_success flag to True. The flag is used by the [query\_success](#query-success) method.

* * *

### StreamlitDeleteData

The class inherits from the StreamlitHandler class with additional methods for editing rows in the table.

Although in the tutorial I am showing how to delete the rows, I would suggest only deleting table rows when you are keeping table history. If don't have temporal (system-versioned) tables I would suggest the table structure uses a delete column to mark the row as deleted. And you an update query to change the column value.

#### Methods

##### data\_editor\_formatted

```
        """
        Will return a formatted data_editor widget

        Returns
        -------
        streamlit data_editor widget
        """
        # get the source table data
        self.fetch_table_data(row_params=((self.current_page-1)*self.rows_per_page,
                                          self.rows_per_page,
                                          ))

        # add column to data set
        self.table_data["Select"] = False
        
        # set the column order
        self._column_order = ('Select',) + self._column_order

        return(st.data_editor(data=self.table_data, 
                              key="data_editor_delete",
                              use_container_width=True,
                              column_order=self._column_order,
                              ))
```

Using the [fetch\_table\_data](#fetch-table-data) method will fetch the data from the source table. Will pass the offset and number of rows to return to the query to the row\_params parameter. The values have to be passed as a tuple.

Once the data is returned will add a column to the data frame named Select, and set its value to False. The column will shown as a checkbox in the data\_editor widget.

Next we reset the column order so the first column is the Select column.

Lastly, return the streamlit data\_editor widget to the user.

##### prompt\_for\_confirmation

```
    def delete_source_data(self, delete_data: pd.DataFrame):
        """
        After user confirms the deletion execute the delete 
        commands against the source database

        Parameters
        ----------
        edited_data : pandas DataFrame
            DataFrame only contains the rows to be deleted.

        """
        self.deletion_requested = False

        # Retrieve selected rows from session state for deletion
        for row_id in delete_data[self.primary_key_column_name]:
            self.data_handler.delete_row(self._source_table_name, 
                                         primary_key_column=self.primary_key_column_name,
                                         row_id=row_id)
        self._query_success = True
```

First will reset the flag deletion\_requested to False, so we don't try and delete the same rows twice, if the deletion fails.

Next will extract all of the primary key ids that have been selected. In the [delete\_row.py callback](#pages-delete-row-main-confirmation) to delete\_source\_data, we filtered the rows being passed to the method through the args.

```
args=(table_data.query("Select == True"),))
```

The Pandas data frame query method ensures we are only deleting rows that the user selected.

Next page will talk about the DataHandler Class

* * *

## Data Handler Class

The class has a few helper methods to aid in sending data between Microsoft SQL and Pandas data frames. The class uses the PandasSqlHandler class.

1. [Data Handler Class](https://eipsoftware.com/musings/streamlit-crud-app/?page=5#data-handler-class)
    1. [Methods](https://eipsoftware.com/musings/streamlit-crud-app/?page=5#methods-1)
        1. [\_adjust\_dataframe\_types](https://eipsoftware.com/musings/streamlit-crud-app/?page=5#adjust-dataframe-types)
        2. [\_\_sql\_to\_pandas\_dtype](https://eipsoftware.com/musings/streamlit-crud-app/?page=5#sql-to-pandas-dtype)
        3. [get\_table\_columns](https://eipsoftware.com/musings/streamlit-crud-app/?page=5#get-table-columns)
        4. [add\_row](https://eipsoftware.com/musings/streamlit-crud-app/?page=5#add-row)
        5. [update\_row](https://eipsoftware.com/musings/streamlit-crud-app/?page=5#update-row)
        6. [delete\_row](https://eipsoftware.com/musings/streamlit-crud-app/?page=5#delete-row)

### Methods

\_\_init\_\_

```
    def __init__(self, db_handler:PandasSqlHandler):
        self.db_handler = db_handler
```

Assign the PanadaSqlHandler class.

#### \_adjust\_dataframe\_types

```
    def _adjust_dataframe_types(self, df):
        """ Adjusts the DataFrame's data types to be compatible with SQL Server """
        for column in df.columns:
            match df[column].dtype:
                case 'float64':
                    df[column] = df[column].astype('float32')  # Adjust precision if needed
                case 'int64':
                    df[column] = df[column].astype('int32')  # Adjust for SQL Server int handling
                case 'object':
                    df[column] = df[column].astype('str')  # Ensure text data type compatibility                
        return df
```

Loop through the columns and set the convert the pandas data type to a data type that Microsoft SQL can support.

#### \_\_sql\_to\_pandas\_dtype

```
    def __sql_to_pandas_dtype(self, sql_type:str):
        """converts sql data type to appropirate pandas datatype
        
        Parameters
        ----------
        sql_type : str 
        """
        match sql_type.lower():
            case 'int':
                return np.int32
            case 'varchar':
                return str
            case 'nvarchar':
                return str
            case 'date' | 'datetime' | 'datetime2':
                return 'datetime64[ns]'
            case 'bit':
                return 'bool'
            case _ :
                return object
```

Convert Microsoft SQL datatypes to applicable Pandas data frame datatype.

#### get\_table\_columns

```
    def get_table_columns(self, query:str, filter_columns:list, query_params:tuple=None):
        """
        Get the meta data about the table, including the column name
        and sql data type.  The sql data type will be converted to a pandas
        data type.

        Parameters
        ----------
        query : str 
            query used to find the list of columns and data types
        filter_columns : list 
            to filter columns to show to user
        query_params : tuple, optional
            parameters to be inserted into the query
        
        """
        # convert filter_columns to a string
        filter_columns = "','".join(filter_columns)
       
        # get the data frame and apply filter to it
        metadata_df = self.db_handler.read_table(query=query, params=query_params)
        metadata_df = self._adjust_dataframe_types(metadata_df).query(f"COLUMN_NAME in ['{filter_columns}']")
        
        column_info = dict(zip(metadata_df["COLUMN_NAME"],
                               metadata_df["DATA_TYPE"].apply(self.__sql_to_pandas_dtype)
                               ))
        
        return column_info
```

Filter columns are stored in the config / sql\_column\_config.yaml file. We may only want to show certain columns to the user.

Next we query the database and read the column meta data. Then we drop any rows that are not in the filter columns list.

Lastly we return a dictionary with the column name and the converted the data\_type from Microsoft SQL data type to a Pandas datatype.

#### add\_row

```
    def add_row(self, table_name:str, data: pd.DataFrame):
        """
        Ensure compatible data types for SQL Server before inserting

        Parameters
        ----------
        table_name : str
            The name table to add a row to. Table name should include
            the schema and table name.  i.e
            
            - dbo.my_table_name
            - log.my_other_table

        data : pandas.DataFrame
            Data frame holding the data to be inserted into the source table
        """
        
        if not isinstance(data, pd.DataFrame) or len(data) != 1:
            raise ValueError("row data should be a pandas DataFrame with a single row")
        
        # Pass the row data to the PandasSQLHandler to handle the database insertion
        #self.db_handler.insert_row(table_name, row_data)
        row_dict = data.iloc[0].to_dict()
        # Create an SQL INSERT statement with placeholders
        columns = ', '.join(row_dict.keys())
        placeholders = ', '.join([f":{col}" for col in row_dict.keys()])
        query = f"INSERT INTO {table_name} ({columns}) VALUES ({placeholders})"
        self.db_handler.execute_query(query, row_dict)
```

We check that the data is a Pandas data frame and there is only one data frame. If there is an issue we raise an error. The method does allow to insert multiple rows at the same time.

We use the first row to create a dictionary variable called row\_dict. It will be used to create the placeholders.

Next we grab the list of column names and store them in the columns variable.

Next we create the placeholders, and join them together as a string. The placeholders are the values to insert into the table.

Next we will format the query string, inserting the table name, columns, and placeholders.

Lastly will execute the query.

#### update\_row

```
def update_row(self, table:str, update_data:dict, primary_key_column:str, row_id):
        """
        Build an UPDATE query dynamically based on changed column values

        Parameters
        ----------
        table_name : str
            The name table to update row data. Table name should include
            the schema and table name.  i.e
            
            - dbo.my_table_name
            - log.my_other_table

        update_data : dict
           Dictionary holding column name value to be updated in the 
           source table

        primary_key : str
            column name that represents the primary key.

        row_id : any
            The row to be upated.

        """
        # Convert all values to native Python types (e.g., int, str)
        update_data = {key: (value.item() if hasattr(value, 'item') else value) for key, value in update_data.items()}

        row_id = int(row_id)
        set_clause = ", ".join([f"{col} = :{col}" for col in update_data.keys()])
        query = f"UPDATE {table} SET {set_clause} WHERE {primary_key_column} = :row_id"

        # Execute the query with the values for each column and row ID
        params = {**update_data, 'row_id': row_id}
        
        self.db_handler.execute_query(query, params)   
```

Similiar to the add\_row method, we will prepare the query and merge into a string and execute.

First create a dictionary update\_data for all the columns and their applicable values to be updated.

Next due a conditional conversion on row\_id so that it is converted to int 32 if an int 64 value.

Next create the string that will hold the column names and the updated value.

Next merge the update\_data dictionary and row\_id value into one dictionary that can be passed to the execute\_query method.

Lastly execute the query.

#### delete\_row

```
    def delete_row(self, table_name:str, primary_key_column:str, row_id):
        """
        Build a delete query dynamically based on changed column values

        Parameters
        ----------
        table_name : str
            The name table to update row data. Table name should include
            the schema and table name.  i.e
            
            - dbo.my_table_name
            - log.my_other_table

        update_data : dict
           Dictionary holding column name value to be updated in the 
           source table

        primary_key : str
            column name that represents the primary key.

        row_id : any
            The row to be upated.

        """
        query = f"DELETE FROM {table_name} WHERE {primary_key_column} = {row_id}"
        self.db_handler.execute_query(query)
```

Create a query string to indicate which row to delete from the table.

First create the string merging the table\_name and the row\_id.

Execute the sql query using the execute\_query method.

Next page will talk about the PandasSQLHandler Class

## PandasSqlHandler

The class has a few helper methods for setting up the database connection, assigning the database environment, reading tables, and executing queries.

1. [PandasSqlHandler](https://eipsoftware.com/musings/streamlit-crud-app/?page=6#pandassqlhandler)
    1. [Methods](https://eipsoftware.com/musings/streamlit-crud-app/?page=6#methods-2)
        1. [\_\_init\_\_](https://eipsoftware.com/musings/streamlit-crud-app/?page=6#init)
        2. [\_\_assign\_conn\_str](https://eipsoftware.com/musings/streamlit-crud-app/?page=6#assign-conn-str)
        3. [read\_table](https://eipsoftware.com/musings/streamlit-crud-app/?page=6#read-table)
        4. [execute\_query](https://eipsoftware.com/musings/streamlit-crud-app/?page=6#execute-query)

### Methods

#### \_\_init\_\_

```
    def __init__(self, environment):
        """Class to run SQL queries against MSFT database
        
        Parameters
        ----------
        None

        Methods
        ----------
        run_query(user_query) -> dataframe
            returns the query results in a list of dictionaries
        """
    
        self._environment:str   = environment
        self._conn_str:str      = self.__assign_conn_str()
        self._conn_url          = sql.engine.URL.create("mssql+pyodbc", query={"odbc_connect": self._conn_str})
        self.engine             = sql.create_engine(self._conn_url)   
```

First assign the environment. Environment configurations are set up in the config/sql\_config.yaml file.

Next based on the environment, return the SQL\_Driver string from the config/sql\_config.yaml file.

Next combine the connection elements into the URL formatted string

Lastly invoke the sql alchemy create engine method.

#### \_\_assign\_conn\_str

```
    def __assign_conn_str(self) -> str:
        match self._environment.lower():
            case 'dev':
                return sql_config.sql.dev.SQL_DRIVER
            case 'prod':
                return sql_config.sql.prod.SQL_DRIVER
            case _ :
                return sql_config.sql.dev.SQL_DRIVER
```

The method will read config/sql\_config.yaml file, and return the applicable SQL\_Driver string from the config/sql\_config.yaml file.

#### read\_table

```
    def read_table(self, query, params=None) -> pd.DataFrame:
        """
        Run the SQL query and return the results in a Pandas dataframe

        Returns
        ----------
        Pandas Dataframe
        """
        return pd.read_sql(sql=query, con=self.engine, params=params)
```

Using Pandas package, call the read\_sql method and return a Pandas Dataframe.

#### execute\_query

```
    def execute_query(self, user_query:str, params=None) -> None:
        """
        Run and commit the sql query
        """
        with self.engine.connect() as connection:
            connection.execute(sql.text(user_query), params or {})
            connection.commit()
```

With the sql database connection defined earlier, execute the sql query and commit the query.

On the next page we will discuss the configuration files.

## Configuration Files

We will use .yaml files to help with configuring the app for the local environment.

1. [Configuration Files](https://eipsoftware.com/musings/streamlit-crud-app/?page=7#configuration-files)
    1. [sql\_config.yaml](https://eipsoftware.com/musings/streamlit-crud-app/?page=7#sql-config-yaml)
    2. [streamlit\_config.yaml](https://eipsoftware.com/musings/streamlit-crud-app/?page=7#streamlit-config-yaml)
    3. [sql\_column\_config.yaml](https://eipsoftware.com/musings/streamlit-crud-app/?page=7#sql-column-config-yaml)

### sql\_config.yaml

```
sql:
  dev:
    SERVER_NAME: "DEV-SERVER"
    DATABASE_NAME: "MY_DATABASE"
    SQL_DRIVER: >
      Driver=SQL Server;
      Server=DEV-SERVER;
      Database=MY_DATABASE;
      Trusted_Connection=yes;

  prod:
    SERVER_NAME: "PROD-SERVER"
    DATABASE_NAME: "MY_DATABASE"
    # for LINUX server
    SQL_DRIVER: >
      Driver={ODBC Driver 18 for SQL Server};
      Server=PROD-SERVER.azure.com;
      Database=MY_DATABASE;
      Trusted_Connection=yes;
      TrustServerCertificate=yes;
```

use sql: for the root.

Then add the environment names you would like to define, in this case I defined an environment for dev, and prod.

Next define the SQL\_Driver connection string.

* * *

### streamlit\_config.yaml

Used for configuration options for Streamlit UI elements.

```
selectbox:
  rows_per_page:
    OPTIONS:
      - 10
      - 20
      - 50
      - 100
```

The select box, allows for showing # of rows per page. It will paginate the data shown in the data\_editor widgets.

* * *

### sql\_column\_config.yaml

The configuration file defines what tables and what columns you wish to return to the user.

```
table:
  countryregion:
    SCHEMA: person
    NAME: countryregion
    PRIMARY_KEY: "ID"
    COLUMNS:
    - CountryRegionCode
    - Name
    - ModifiedDate
  person:
    SCHEMA: person
    NAME: person
    PRIMARY_KEY: "BusinessEntityID"
    COLUMNS:
    - PersonType
    - NameStyle
    - Title
    - FirstName
    - MiddleName
    - LastName
    - EmailPromotion
    - Suffix
  location:
    SCHEMA: production
    NAME: location
    PRIMARY_KEY: "LocationID"
    COLUMNS:
    - Name
    - CostRate
    - Availability    
info:
  columns:
    QUERY: info.columns
  count:
    QUERY: sys.row_count.sql
```

There are two base groups, table and info.

The table group specifies which tables the user can modify. The key is that the name of the table, needs to match the file placed in the query directory.

For our example we allow the user to update the production.location table. Therefore there needs to be a corresponding file in the / query directory, labeled query / production.location.sql

In the second base group there are two informational queries. info.columns, which is used to return the meta data from the database. And the second query sys.row\_count which is used to look at the sys tables and get the row count of files.

On the next page, we will review the example query files.

## Query

We have two informational queries.

### info.columns

```
SELECT	[INFORMATION_SCHEMA].[COLUMNS].[COLUMN_NAME]
		, [INFORMATION_SCHEMA].[COLUMNS].[DATA_TYPE]
		, [INFORMATION_SCHEMA].[COLUMNS].[IS_NULLABLE]
		, [INFORMATION_SCHEMA].[COLUMNS].[CHARACTER_MAXIMUM_LENGTH]
		, [INFORMATION_SCHEMA].[COLUMNS].[NUMERIC_PRECISION]
		, [INFORMATION_SCHEMA].[COLUMNS].[NUMERIC_SCALE]
		, [INFORMATION_SCHEMA].[COLUMNS].[COLUMN_DEFAULT]
		, [INFORMATION_SCHEMA].[COLUMNS].[COLLATION_NAME]
FROM	[INFORMATION_SCHEMA].[COLUMNS]
WHERE	[INFORMATION_SCHEMA].[COLUMNS].[TABLE_SCHEMA] 		= ?
		AND [INFORMATION_SCHEMA].[COLUMNS].[TABLE_NAME]		= ?
;
```

File name: query / info.columns.sql

Return the columns meta data for a specified table.

* * *

### sys.row\_count

```
SELECT	SUM(row_count)			row_count
FROM	sys.dm_db_partition_stats
WHERE	object_id = OBJECT_ID(?)
		AND index_id < 2
;
```

File name: query / sys.row\_count.sql

Shows the row counts for the specified table.

* * *

### Table Query - Example

```
SELECT		  Name
		, CostRate
		, Availability
		, ModifiedDate
FROM		production.location
ORDER BY	LocationID
OFFSET		? ROWS FETCH NEXT ? ROWS ONLY
;
```

File name: query / production.location

Need to use placeholders (?) to allow for the OFFSET statement.

## Github Files

Github files are located here.

[Streamlit Table Editor](https://github.com/mmooney512/musings/tree/main/python%20/streamlit%20table%20editor)
