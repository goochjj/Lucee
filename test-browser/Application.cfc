component {

  this.mappings['/testbox'] = getDirectoryFromPath( getCurrentTemplatePath() ) & '/testbox';
  this.mappings['/Lucee'] = getDirectoryFromPath( getCurrentTemplatePath() ) & '/../';

  function onRequestStart() {
    Request.WEBADMINPASSWORD="webweb";
	try {
                    admin
                                action="updatePassword"
                                type="web"
                                oldPassword=""
                                newPassword="#request.WEBADMINPASSWORD#";
                }
                catch(e){}// may exist from previous execution

                try {
                    admin
                                action="updatePassword"
                                type="server"
                                oldPassword=""
                                newPassword="#request.WEBADMINPASSWORD#";
                }
                catch(e){}// may exist from previous execution

  }
}
