<template>
  <div >
    <!--FTP预览对话框-->
      <vueshowpdf
        @closepdf="closepdf"
        v-model="isshowpdf"
        :pdfurl="fileUrl"
        @pdferr="pdferr"
        :maxscale="4"
        :minscale="0.6"
        :scale="1.0"
      >
      </vueshowpdf>
    <!--word文件预览-->
     <!--word文件预览-->
    <el-dialog 
      @close="dialogClose"
      :visible.sync="isShowFileWord"
      width="60%"
      append-to-body
    >
        <div ref="file"></div>
    </el-dialog>
      
  </div>
</template>


<script>
import vueshowpdf from "vueshowpdf";
import Axios from "axios";
let docx = require("docx-preview");
export default {
  name: "preview",
  components: { vueshowpdf },
  props: ['showExt', 'fileUrl'],
  data() {
    return {
      //FTP路径
      //FTP预览对话框是否打开
      isshowpdf: false,
      isShowFileWord: false,
      openReviewDialog: false,
    };
  },
  created(){
  },
watch: {
  showExt (val) {
    debugger
    if (val == 'docx') {
      this.getPdfCode(this.fileUrl);
      this.isShowFileWord = true
       
    }
    if(val == 'pdf'){
       this.isshowpdf = true;
    }
  }
},

  methods: {
    //关闭pdf预览
    closepdf() {
      this.$emit('closepdf')
      this.isshowpdf = false;
    },
    //pdf预览出错
    pdferr(errurl) {
      console.log(errurl);
    },
    //加载word预览
    getPdfCode(fileUrl) {
      debugger
      Axios({
        method: "get",
        responseType: "blob",
        url: fileUrl,
      }).then(({ data }) => {
        docx.renderAsync(data, this.$refs.file); // 渲染到页面
      });
    },
    //对话框关闭事件
    dialogClose(){
      this.isShowFileWord = false;
      this.$emit('closepdf')
    }
  },
};
</script>

<style>
</style>