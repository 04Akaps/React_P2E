import React, { useState, useEffect } from "react";
import "./DetailWorld.scss";
import axios from "axios";
function DetailWorld() {
  const idx = useState(window.location.pathname.split(":")[1]);
  const [data, SetData] = useState(false);

  useEffect(() => {
    const getData = async () => {
      await axios
        .get(`http://localhost:8080/Map/detail/${idx[0]}`)
        .then((result) => SetData(result.data));
    };
    getData();
  }, []);

  //   <img
  //             className="Loading"
  //             src="https://t1.daumcdn.net/cfile/tistory/233F6D505786DA870A"
  //             alt="loading"
  //           />
  console.log(data);
  return <div>sdfsdf</div>;
}

export default DetailWorld;
