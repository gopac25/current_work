node {

  String separatorStyle = '''
      border: 0;
      border-bottom: 0px dashed #ccc;
      background: #999;
  '''

  String headerStyle = '''
      color: white;
      background: grey;
      font-family: Roboto, sans-serif !important;
      padding: 5px;
      text-align: center;
  '''
def build_ok = true
properties([
  parameters([
          string(defaultValue: '', description: 'Specify the jenkins node. Default node is master', name: 'Jenkins_Node'),
          string(defaultValue: '', description: 'Specify the AWS_ACCESS_KEY_ID', name: 'AWS_ACCESS_KEY_ID'),
          string(defaultValue: '', description: 'Specify the AWS_SECRET_ACCESS_KEY', name: 'AWS_SECRET_ACCESS_KEY'),
          string(defaultValue: 'master', description: 'git branch name of the scripts repository', name: 'git_branch_name'),
          booleanParam(defaultValue: false, description: 'Create infrastructure', name: 'create_infra'),
          booleanParam(defaultValue: false, description: 'Destroy infrastructure', name: 'destroy_infra'),
        ])
      ])
      // Setting up the build display name
      currentBuild.displayName = "Infra - build - " + "#" + env.BUILD_ID
  // Environment Variables
  env.PATH += ":/usr/local/bin"

    stage ('Checkout') {
    git(
       url: 'https://github.com/gopac25/final_infra.git',
       branch: "${git_branch_name}"
    )
  }
  
      try {
		
        if (create_infra.toBoolean()) {
          stage ('Terraform initialize') {
             sh 'terraform init'
            }
  
          stage ('Terraform Plan') {
             sh 'terraform plan -no-color -out=create.tfplan'
             }
          stage ("Terraform Apply") {
            sh 'terraform apply -no-color create.tfplan'
             }
          stage ("Aws Configure") {
            sh 'aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID'
            sh 'aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY'
            sh 'aws configure set default.region ap-south-1'
            sh 'aws configure set default.output text'
            sh 'sh inven.sh'
          }
        }

        if (destroy_infra.toBoolean()) {
          stage ("Terraform Destroy") {
            sh 'terraform destroy -auto-approve'
          }
        }
      } catch (e) {
        build_ok = false
        echo e.toString()
      }

      if(build_ok) {
        currentBuild.result = "SUCCESS"
      } else {
        currentBuild.result = "FAILURE"
      }
    }
