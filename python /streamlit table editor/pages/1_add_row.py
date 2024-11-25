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
