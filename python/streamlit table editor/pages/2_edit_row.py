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
            st.success("Updates saved to the database.")

if __name__ == "__main__":
    main()    