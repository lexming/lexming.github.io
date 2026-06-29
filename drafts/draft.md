
    #@mock.patch('vsc.filesystem.posix.PosixOperations._execute')
    @mock.patch('vsc.utils.run.Run._init_process')
    @mock.patch('vsc.filesystem.posix.PosixOperations._what_filesystem')
    def test_replace_acl(self, mock_what_filesystem, mock_process):
        """
        Test replacement of ACLs
        """
        #mock_execute.return_value = (0, "")
        def mock_process(self, *a, **k):
            raise Exception(self._shellcmd)

        test_path = '/tmp/test'

        # POSIX ACLs
        mock_what_filesystem.return_value = ['posix', '/data', 0, '127.0.0.1@tcp']

        test_acl_posix = "user::rwx"
        self.assertRaises(PosixOperationError, self.po.replace_acl, test_path, test_acl_posix)

        test_acl_posix = ["user::rwx", "group::r-x", "other::r-x"]
        from vsc.utils.run import Run
        with mock.patch.object(Run, "_wait_for_process", new=mock_process):
            ec = self.po.replace_acl(test_path, test_acl_posix)
        #mock_execute.assert_called_with(
        #    ['printf', '"user::rwx\ngroup::r-x\nother::r-x"', '|', 'setfacl', '--set-file=-', '/tmp/test']
        #)
        self.assertEqual(ec, "potato")
