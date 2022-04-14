<template>
  <div class="app-container">
    <el-row :gutter="20">
      <!--分类数据-->
      <el-col :span="4" :xs="24">
        <div class="head-container">
          <el-input
            v-model="className"
            placeholder="请输入分类名称"
            clearable
            size="small"
            prefix-icon="el-icon-search"
            style="margin-bottom: 20px"
          />
        </div>
        <div class="head-container">
          <el-tree
            :data="classificationOptions"
            :props="defaultProps"
            :expand-on-click-node="false"
            :filter-node-method="filterNode"
            ref="tree"
            default-expand-all
            @node-click="handleNodeClick"
          />
        </div>
      </el-col>
      <el-col :span="20" :xs="24">
        <el-form
          :model="queryParams"
          ref="queryForm"
          v-show="showSearch"
          :inline="true"
        >
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

        <el-row :gutter="10" class="mb8">
          <el-col :span="1.5">
            <el-button
              type="primary"
              plain
              icon="el-icon-plus"
              size="mini"
              @click="handleAdd"
              >上传</el-button
            >
          </el-col>
          <right-toolbar
            :showSearch.sync="showSearch"
            @queryTable="getList"
          ></right-toolbar>
        </el-row>

        <el-table
          v-loading="loading"
          :data="fileList"
          row-key="id"
          :tree-props="{ children: 'children', hasChildren: 'hasChildren' }"
        >
          <el-table-column label="文件编号" prop="id" />
          <el-table-column
            label="文件名称"
            prop="fileName"
            :show-overflow-tooltip="true"
          />
          <el-table-column
            label="文件大小"
            prop="fileSize"
            :show-overflow-tooltip="true"
          >
           <template slot-scope="scope">
              {{ (scope.row.fileSize/1024).toFixed(2) }}KB
            </template>
           
          </el-table-column>
          <el-table-column
            label="文件后缀标识"
            prop="fileExt"
            :show-overflow-tooltip="true"
          />
  
          <el-table-column
            label="文件分类"
            key="fileClassId"
            prop="classification.className"
            :show-overflow-tooltip="true"
          />
          <el-table-column
            label="所属关键词"
            key="keywordIds"
            prop="keywordIds"
            :show-overflow-tooltip="true"
          >
          <template slot-scope="scope">
             <el-tag
              v-for="keyword in scope.row.libKeywordList"
              :key="keyword.id"
            >
              {{ keyword.keywordName }}
            </el-tag>
            </template>
           
          </el-table-column>
         
          <el-table-column label="创建时间" align="center" prop="createTime">
            <template slot-scope="scope">
              <span>{{ parseTime(scope.row.createTime) }}</span>
            </template>
          </el-table-column>
          <el-table-column
            label="操作"
            align="center"
            class-name="small-padding fixed-width"
          >
            <template slot-scope="scope">
              <el-button
                size="mini"
                type="text"
                icon="el-icon-look"
                @click="preview(scope.row)"
                >查看</el-button
              >
              <el-button
                size="mini"
                type="text"
                icon="el-icon-edit"
                @click="handleUpdate(scope.row)"
                >修改</el-button
              >
              <el-button
                size="mini"
                type="text"
                icon="el-icon-delete"
                @click="handleDelete(scope.row)"
                >删除</el-button
              >
            </template>
          </el-table-column>
        </el-table>

        <pagination
          v-show="total > 0"
          :total="total"
          :page.sync="queryParams.pageNum"
          :limit.sync="queryParams.pageSize"
          @pagination="getList"
        />
      </el-col>
    </el-row>
    <!-- 上传文件对话框 -->
    <el-dialog :title="title" :visible.sync="open" width="500px" append-to-body>
      <el-form ref="form" :model="form" :rules="rules" label-width="100px">
        <el-upload
          class="upload-demo"
          action="http://192.168.0.133:8080/file/upload"
          :headers="headers"
          :before-upload="beforeAvatarUpload"
          :on-success="handleAvatarSuccess"
          multiple
          :limit="3"
          :on-exceed="handleExceed"
          :file-list="fileList"
        >
          <el-button size="small" type="primary">点击上传</el-button>
          <div slot="tip" class="el-upload__tip">只能上传不超过10MB的文件</div>
        </el-upload>
      </el-form>
    </el-dialog>
    <!-- 修改对话框 -->
    <el-dialog
      :title="title"
      :visible.sync="updateDialog"
      width="500px"
      append-to-body
    >
      <el-form ref="form" :model="form" :rules="rules" label-width="100px">
        <el-form-item label="文件名称" prop="fileName">
          <el-input v-model="form.fileName" placeholder="请选择文件名称" />
        </el-form-item>
        <el-form-item label="文件分类" prop="fileClassId">
          <el-cascader
            v-model="form.fileClassId"
            :options="classificationOptions"
            :props="{ checkStrictly: true }"
            :show-all-levels="false"
            clearable
            @change="handleFileClassIdChange"
          ></el-cascader>
        </el-form-item>
        <el-form-item label="关键词" prop="keywordIds">
          <el-select
            v-model="form.keywordIds"
            multiple
            placeholder="请选择关键词"
          >
            <el-option
              v-for="item in keywordOptions"
              :key="item.id"
              :label="item.keywordName"
              :value="item.id"
            ></el-option>
          </el-select>
        </el-form-item>
        <el-form-item label="文件简介" prop="fileBrief">
          <el-input
            type="textarea"
            autosize
            v-model="form.fileBrief"
            placeholder="请输入文件简介"
          />
        </el-form-item>
      </el-form>
      <div slot="footer" class="dialog-footer">
        <el-button type="primary" @click="submitForm">确 定</el-button>
        <el-button @click="cancel">取 消</el-button>
      </div>
    </el-dialog>
    <!--预览插件-->
    <preview
      v-bind:showExt="showExt"
      :fileUrl="fileUrl"
      @closepdf="closepdf"
    ></preview>
  </div>
</template>

<script>
import {
  listFile,
  getFile,
  delFile,
  updateFile,
  addFile,
  viewFile,
} from "@/api/lib/file";
import { optionselect } from "@/api/lib/keyword";
import { getTreeselect } from "@/api/lib/classification";
import { getToken } from "@/utils/auth";
import Preview from "@/components/filePreview/preview.vue";
// let loading;
export default {
  name: "File",
  components: {
    Preview,
  },
  data() {
    return {
      // 遮罩层
      loading: false,
      // 选中数组
      ids: [],
      // 非单个禁用
      single: true,
      // 非多个禁用
      multiple: true,
      // 显示搜索条件
      showSearch: true,
      // 总条数
      total: 0,
      // 文件表格数据
      fileList: [],
      // 弹出层标题
      title: "",
      // 是否显示弹出层
      open: false,
      //所属父类
      parentId: [],
      //分类选择选项
      classificationOptions: [],
      //关键词选项
      keywordOptions: {},
      //完善文件对话框
      updateDialog: false,

      // 查询参数
      queryParams: {
        pageNum: 1,
        pageSize: 10,
        className: undefined,
        fileName:undefined
      },
      defaultProps: {
        children: "children",
        label: "label",
      },
      // 分类名称
      className: undefined,
      // 表单参数
      form: {},
      // 表单校验
      rules: {
        className: [
          { required: true, message: "文件名称不能为空", trigger: "blur" },
        ],
      },
      //上传文件的list
      fileList: [],
      config: {
        Authorization: "Bearer " + getToken(),
      },
      fileUrl: undefined,
      showExt: undefined,
      //限制不上大于10M的文件
      LtM: 10,
    };
  },
  created() {
    this.getList();
    this.loadClassificationTreeselect();
    this.loadKeywordList();
  },
  computed: {
    headers() {
      return {
        Authorization: "Bearer " + getToken(),
      };
    },
  },
  watch: {
    // 根据名称筛选部门树
    className(val) {
      this.$refs.tree.filter(val);
    },
  },
  methods: {
    /** 查询文件列表 */
    getList() {
      this.loading = true;
      listFile(this.queryParams).then((response) => {
        this.fileList = response.rows;
        this.loading = false;
      });
    },
    // 筛选节点
    filterNode(value, data) {
      if (!value) return true;
      return data.label.indexOf(value) !== -1;
    },
    // 节点单击事件
    handleNodeClick(data) {
      this.queryParams.fileClassId = data.value;
      this.getList();
    },

    // 取消按钮
    cancel() {
      this.open = false;
      this.reset();
    },
    // 表单重置
    reset() {
      this.form = {
        className: undefined,
      };
      this.resetForm("form");
    },
    /** 搜索按钮操作 */
    handleQuery() {
      this.queryParams.pageNum = 1;
      this.getList();
    },
    /** 重置按钮操作 */
    resetQuery() {
      this.resetForm("queryForm");
      this.handleQuery();
    },

    /** 新增按钮操作 */
    handleAdd() {
      this.reset();
      this.open = true;
      this.title = "上传文件";
      this.fileList = [];
    },

    /** 修改按钮操作 */
    handleUpdate(row) {
      this.reset();
      const fileId = row.id || this.ids;
      getFile(fileId).then((response) => {
        this.form = response.data;
        this.form.keywordIds = response.keywordIds;
        this.updateDialog = true;
        this.title = "修改文件内容";
      });
    },
    /** 获取分类树形*/
    loadClassificationTreeselect() {
      getTreeselect().then((response) => {
        this.classificationOptions = response.data;
      });
    },
    /**获取关键词列表 */
    loadKeywordList() {
      optionselect().then((response) => {
        this.keywordOptions = response.data;
      });
    },

    /** 提交按钮 */
    submitForm: function () {
      debugger;
      this.$refs["form"].validate((valid) => {
        if (valid) {
          let fileClassId = this.form.fileClassId;
          if (fileClassId.length > 0) {
            this.form.fileClassId = parseInt(
              fileClassId[fileClassId.length - 1]
            );
          }
          updateFile(this.form).then((response) => {
            this.msgSuccess("修改成功");
            this.updateDialog = false;
            this.getList();
          });
        }
      });
    },
    /** 删除按钮操作 */
    handleDelete(row) {
      const keywordId = row.id || this.ids;
      this.$confirm(
        '是否确认删除分类编号为"' + keywordId + '"的数据项?',
        "警告",
        {
          confirmButtonText: "确定",
          cancelButtonText: "取消",
          type: "warning",
        }
      )
        .then(function () {
          return delFile(keywordId);
        })
        .then(() => {
          this.getList();
          this.msgSuccess("删除成功");
        })
        .catch(() => {});
    },
    /**分类树形onchange事件 */
    handleFileClassIdChange(value) {
      console.log(value);
    },
    /**限制选择上传个数 */
    handleExceed(files, fileList) {
      this.$message.warning(
        `当前限制选择 3 个文件，本次选择了 ${files.length} 个文件，共选择了 ${
          files.length + fileList.length
        } 个文件`
      );
    },

    /**上传成功后添加数据到后台 将上传后的地址保存到数据库 */
    handleAvatarSuccess(res, file) {
      if (res.code === 200) {
        let fileInfo = {};
        fileInfo.fileName = file.name;
        fileInfo.fileSize = file.size;
        fileInfo.fileExt = file.name.split(".").pop();
        fileInfo.fileUuid = file.uid;
        fileInfo.filePath = res.data.url;
        addFile(fileInfo).then((response) => {
          this.msgSuccess("新增成功");
        });
      }
    },

    beforeAvatarUpload(file) {
      // 文件类型进行判断
      const isLtM = file.size / 1024 / 1024 < LtM;
      if (!isLtM) {
        this.$message.error("上传文件大小不能超过" + LtM + "MB!");
      }
      return isLtM;
    },
    /**文件预览 */
    preview(row) {
      if (row.fileExt == "pdf") {
        this.showExt = "pdf";
        this.fileUrl = row.filePath;
      } else if (row.fileExt == "docx" || row.fileExt == "doc") {
        this.showExt = "docx";
        this.fileUrl = row.filePath;
      } else if (row.fileExt == "png" || row.fileExt == "jpg") {
        window.open(row.filePath);
      } else {
        this.$message.error("暂不支持这个格式的预览");
      }
    },
    //关闭pdf预览
    closepdf() {
      this.showExt = undefined;
    },
  },
};
</script>