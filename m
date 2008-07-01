From: Paul Jackson <pj@sgi.com>
Subject: Re: Attaching PID 0 to a cgroup
Date: Tue, 1 Jul 2008 13:54:09 -0500
Message-ID: <20080701135409.5e68ccd8.pj@sgi.com>
References: <20080701094545.GD3925@linux.vnet.ibm.com>
	<20080701094734.GE3925@linux.vnet.ibm.com>
	<486A06B7.7020906@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758742AbYGASyW@vger.kernel.org>
In-Reply-To: <486A06B7.7020906@cn.fujitsu.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: dhaval@linux.vnet.ibm.com, menage@google.com, akpm@linux-foundation.org, balbir@in.ibm.com, skumar@linux.vnet.ibm.com, linux-kernel@vger.kernel.org, containers@lists.osdl.org
List-Id: containers.vger.kernel.org

> But it's better to document this.

Good idea.

Acked-by: Paul Jackson <pj@sgi.com>

You (Li Zefan) might want to resend this as a patch, in case Andrew
doesn't happen to see this embedded here.

Something like the following:

  Subject: [PATCH] cgroup: document zero pid means current task

  From: Li Zefan <lizf@cn.fujitsu.com>

  Document that a pid of zero(0) can be used to refer to the
  current task when attaching a task to a cgroup, as in the
  following usage:
  
    # echo 0 > /dev/cgroup/tasks

  This is consistent with existing cpuset behavior.

  Signed-off-by: Li Zefan <lizf@cn.fujitsu.com>
  Acked-by: Dhaval Giani <dhaval@linux.vnet.ibm.com>
  Acked-by: Paul Jackson <pj@sgi.com>

  ---
   cgroups.txt |    4 ++++
   1 file changed, 4 insertions(+)

  diff --git a/Documentation/cgroups.txt b/Documentation/cgroups.txt
  index 824fc02..213f533 100644
  --- a/Documentation/cgroups.txt
  +++ b/Documentation/cgroups.txt
  @@ -390,6 +390,10 @@ If you have several tasks to attach, you have to do it one after another:
 	  ...
   # /bin/echo PIDn > tasks

  +You can attach the current task by echoing 0:
  +
  +# /bin/echo 0 > tasks
  +
   3. Kernel API
   =============


-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.940.382.4214
