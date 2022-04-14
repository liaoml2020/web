<template>
  <div class="app-container">
    <el-form :model="queryParams" ref="queryForm" :inline="true">
      <el-form-item label="分类名称" prop="fileClassId">
        <el-cascader
          v-model="queryParams.fileClassId"
          :options="classificationOptions"
          :props="{ checkStrictly: true }"
          :show-all-levels="false"
          clearable
          @change="handleQuery"
        ></el-cascader>
      </el-form-item>
      <el-form-item label="文件名称" prop="fileName">
        <el-input
              v-model="queryParams.fileName"
              placeholder="请输入文件名称"
              clearable
              size="small"
              style="width: 240px"
              @keyup.enter.native="handleQuery"
            />
      </el-form-item>
      <el-form-item label="关键词名称" prop="keywordName">
        <el-select
          v-model="queryParams.keywordIds"
          multiple
          placeholder="请选择关键词"
        >
          <el-option
            v-for="item in keywordOptions"
            :key="item.id"
            :label="item.keywordName"
            :value="item.id"
            clearable
            size="small"
            style="width: 280px"
            @keyup.enter.native="handleQuery"
          ></el-option>
        </el-select>
      </el-form-item>

      <el-form-item>
        <el-button
          type="primary"
          icon="el-icon-search"
          size="mini"
          @click="handleQuery"
          >搜索</el-button
        >
        <el-button icon="el-icon-refresh" size="mini" @click="resetQuery"
          >重置</el-button
        >
      </el-form-item>
    </el-form>
    <el-divider></el-divider>
    <div v-for="(file, index) in fileList" :key="file.id">
      <el-row :gutter="20">
        <el-col :span="6"
          ><img
            class="image"
            src="https://shadow.elemecdn.com/app/element/hamburger.9cf7b091-55e9-11e9-a976-7f4d0b07eef6.png"
            @click="preview(file)"
        /></el-col>
        <el-col :span="18">
          <el-row><div class="fileNameStyle"><el-link type="info" :href="file.filePath">{{ file.fileName }}</el-link ></div></el-row
          >
          <el-row
            ><div>创建时间:{{ file.createTime }}</div></el-row
          >
          <el-row
            ><div>
              关键词：
              <el-tag v-for="keyword in file.libKeywordList" :key="keyword.id">
                {{ keyword.keywordName }}
              </el-tag>
            </div>
          </el-row>
          <el-row
            ><div>简介：{{ file.brief }}</div></el-row
          >
        </el-col>
      </el-row>
      <el-divider></el-divider>
    </div>
    <pagination
      v-show="total > 0"
      :total="total"
      :page.sync="queryParams.pageNum"
      :limit.sync="queryParams.pageSize"
      @pagination="getList"
    />
    <!--预览插件-->
    <preview
      v-bind:showExt="showExt"
      :fileUrl="fileUrl"
      @closepdf="closepdf"
    ></preview>
  </div>
</template>

<script>
import { listFile, getFile } from "@/api/lib/file";
import { optionselect } from "@/api/lib/keyword";
import { getTreeselect } from "@/api/lib/classification";
import Preview from "@/components/filePreview/preview.vue";
export default {
  name: "public",
  components: {
    Preview,
  },
  data() {
    return {
      // 查询参数
      queryParams: {
        pageNum: 1,
        pageSize: 10,
        keywordIds: undefined,
        fileName: undefined,
        fileClassId: undefined,
      },
      // 表单参数
      form: {},
      //分类选择选项
      classificationOptions: [],
      //关键词选项
      keywordOptions: {},
      //查找出来的文件列表
      fileList: {},
      // 总条数
      total: 0,
      showExt: undefined,
      fileUrl: undefined,
    };
  },
  created() {
    this.getList();
    this.loadClassificationTreeselect();
    this.loadKeywordList();
  },
  methods: {
    /** 搜索按钮操作 */
    handleQuery() {
      this.queryParams.pageNum = 1;
      this.getList();
    },
    /** 重置按钮操作 */
    resetQuery() {
      this.resetForm("queryForm");
      this.queryParams.keywordIds = undefined
      this.handleQuery();
    },
    /**获取关键词列表 */
    loadKeywordList() {
      optionselect().then((response) => {
        this.keywordOptions = response.data;
      });
    },
    /** 获取分类树形*/
    loadClassificationTreeselect() {
      getTreeselect().then((response) => {
        this.classificationOptions = response.data;
      });
    },
    /** 查询角色列表 */
    getList() {
      debugger;
      let fileClassId = this.queryParams.fileClassId;
      if (fileClassId && fileClassId.length > 0) {
        this.queryParams.fileClassId = parseInt(
          fileClassId[fileClassId.length - 1]
        );
      }
      listFile(this.queryParams).then((response) => {
        this.fileList = response.rows;
        this.total = response.total;
        debugger;
      });
    },
    //关闭预览对话框
    closepdf() {
      this.showExt = undefined;
      this.fileUrl = undefined;
    },
    preview(row) {
      debugger;
      if (row.fileExt == "pdf") {
        this.showExt = "pdf";
        this.fileUrl = row.filePath;
      } else if (row.fileExt == "docx" || row.fileExt == "doc") {
        this.showExt = "docx";
        this.fileUrl = row.filePath;
      } else if (row.fileExt == "png" || row.fileExt == "jpg") {
        window.open(row.filePath);
      } else {
        //this.$message.error("暂不支持这个格式的预览");
      }
    },
  },
};
</script>

<style>
.time {
  font-size: 13px;
  color: #999;
}

.image {
  max-width: 120px;
  max-height: 120px;
  display: flex;
  margin-left: 2%;
}

.el-row {
  margin-bottom: 10px;
}
.el-row.el-col {
  border-radius: 4px;
}
.bg-purple-dark {
  background: #99a9bf;
}
.bg-purple {
  background: #d3dce6;
}
.bg-purple-light {
  background: #e5e9f2;
}
.grid-content {
  border-radius: 4px;
  min-height: 36px;
}
.row-bg {
  padding: 10px 0;
  background-color: #f9fafc;
}
.el-tag {
  margin-left: 15px;
}
.el-link {
  font-size: 22px;

}
</style>