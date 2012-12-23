From: Tanu E <tanisshqa-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Ckptinfo error i.e unexpected end of file (read 0 of 8) and restart
	error i.e Bad file discriptor
Date: Sun, 23 Dec 2012 12:48:10 +0530
Message-ID: <CAJJ1Xt5gBpz72_64DxCFmHz8UJ1QfVLP_BtfwHMT5bbvZzmOOQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Hello All,


Please help me to solve the following issue.
while using the restart I am getting error i.e "Bad file discriptor"
also the ckptinfo giving me error i.e unexpected end of file (read 0 of 8)

I followed the below steps:
1. checked out the code from:
        linux-cr : http://www.linux-cr.org/git/?p=linux-
cr.git;a=shortlog;h=refs/heads/ckpt-v23-rc2
        user-cr  : http://www.linux-cr.org/git/?p=user-
cr.git;a=shortlog;h=refs/heads/master
        tests-cr : http://www.linux-cr.org/git/?p=tests-
cr.git;a=shortlog;h=refs/heads/master


2. Enabled the following tokens in the ".config" file.
        CONFIG_CHECKPOINT_SUPPORT=y
        CONFIG_SYSVIPC_CHECKPOINT=y
        CONFIG_CHECKPOINT=y
        CONFIG_NETNS_CHECKPOINT=y
        CONFIG_CHECKPOINT_DEBUG=y
        CONFIG_CGROUPS=y
        CONFIG_CGROUP_FREEZER=y
        CONFIG_NAMESPACES=y
        CONFIG_CGROUP_NS=y
        CONFIG_UTS_NS=y
        CONFIG_IPC_NS=y
        CONFIG_USER_NS=y
        CONFIG_PID_NS=y
        CONFIG_NET_NS=y
        CONFIG_FREEZER=y

3. After booting the linux-cr. I run the following test code.
   # vim hello.c
      int main(void)
        {
                int i = 0;
                while(1)
                {
                        printf(" i  = %d\n",i);
                        sleep(10);
                }

        }

   #./hello &
   2224 [1]
   #mkdir /cgroup
   #mount -t cgroup -o freezer cgroup /cgroup
   #mkdir cgroup/cg1
   #echo 2224 > /cgroup/cg1
   #echo FROZEN > /cgroup/cg1/freezer.state
   #./checkpoint 2224 > ckpt.image
   #./ckptinfo -ev ckpt.image
        info: [@12] object   1 HDR_HEADER len 72
        ...
        unexpected end of file (read 0 of 8)
   #echo THAWED > /cgroup/cg1/freezer.state
   #./restart < ckpt.image
     error "Bad file discriptor"

   Please let me know how to fix this issue.


Thanks & Regards,
