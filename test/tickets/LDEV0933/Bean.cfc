component name="Bean" {
  property type="string" name="applicationid" getter="true" setter="false" required="true";
  public function setApplicationid(string id) {
    variables.applicationid = id;
  }
  public function getApplicationid() {
    return variables.applicationid;
  }
}
