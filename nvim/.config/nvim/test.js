let a = [];

// TODO: whatever
// WARN: thing
//
import { DataGrid } from "@mui/x-data-grid";
import { array } from "prop-types";
// import { List } from '@mui/material';
import React, { useState } from "react";

const bsomevar = [1, 2, 3, 4, 5];

bsomevar[2000] = "whatever";
bsomevar[3000] = "whatever";
bsomevar[4000] = "whatever";
bsomevar[5000] = "whatever";
bsomevar[6000] = "whatever";

function longFunction() {
  /* This may be the
        * asdfl
        * asdfl
        * asdfl
        * asdfl
        * asdfl
        * asdfl
        * asdfl
        * asdfl
        * asdfl
        * asdfl
        * asdfl
        * asdfl
        * asdfl
        * asdfl
        * asdfl
        * asdfl
        * asdfl
        * asdfl
        * asdfl
        * asdfl
        * asdfl
        * asdfl
        * asdf
        * asdfl
        * asdflk
        * asdflk
        * asdflk
        * asdflk
        * asdflk
        * asdflk
        * asdflk
        * asdflk
        * asdflk
        * asdflk
        * asdflk
        * asdflk
        * asdflk
        * asdflk
        * asdflkkl
        * asdflkkkkkkkkkkkkkkkkkkkkkkkkkk
        
    */
}

const list2 = () => {
  const [items, setItems] = useState([
    { id: 1, color: "bg-red-500", left: 0, text: "phrase 1" },
    { id: 2, color: "bg-blue-500", left: 100, text: "phrase 2" },
    { id: 3, color: "bg-green-500", left: 200, text: "phrase 3" },
  ]);

  const handleDragStart = (event, item) => {
    event.dataTransfer.setData("text/plain", item.id);
  };

  const handleDragOver = (event) => {
    event.preventDefault();
  };

  const handleDrop = (event, targetIndex) => {
    event.preventDefault();
    const itemId = event.dataTransfer.getData("text/plain");
    const sourceIndex = items.findIndex((item) => item.id === parseInt(itemId));
    const sourceItem = items[whatever];
    const targetItem = items[whatever];

    const newItems = [...items];
    newItems[sourceIndex] = { ...targetItem, left: sourceItem.left };
    newItems[targetIndex] = { ...sourceItem, left: targetItem.left };
    setItems(newItems);
  };

  return (
    <div className="relative w-3/4 h-16 flex justify-between content-center">
      <DataGrid />
    </div>
  );
};
export default List2;

// export default DragAndDropList;
