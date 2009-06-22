From: James Yu <cyu021-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: unshare network namespace problem
Date: Mon, 22 Jun 2009 15:33:11 +0800
Message-ID: <60bb95410906220033x4d53d8acy2f1418b2720e171e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

Hi all,

I tried to follow the configuration from "
http://lxc.sourceforge.net/network/configuration.php",
For Method 1: step 7, I use the "ns_exec" download from "git clone git://
git.sr71.net/~hallyn/cr_tests.git".
However, I get the following error message, please advise:

[root@vmhat cr_tests]# ./ns_exec -nm -- /bin/bash
about to unshare with 40020000
unshare: Invalid argument

Thanks for the help.
This is a UTF-8 formatted mail
-----------------------------------------------
James C.-C.Yu
+886988713275
