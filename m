From: Oren Laadan <orenl@cs.columbia.edu>
Subject: Re: [PATCH 1/1] cr: lsm: restore LSM contexts for ipc objects
Date: Thu, 25 Jun 2009 00:21:34 -0400
Message-ID: <4A42FB4E.2070306@cs.columbia.edu>
References: <20090620013216.GA4435@us.ibm.com>	<1245779751.27538.14.camel@localhost.localdomain> <20090623181810.GA23644@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20090623181810.GA23644@us.ibm.com>
Sender: linux-security-module-owner@vger.kernel.org
To: "Serge E. Hallyn" <serue@us.ibm.com>
Cc: Stephen Smalley <sds@epoch.ncsc.mil>, Casey Schaufler <casey@schaufler-ca.com>, linux-security-module@vger.kernel.org, SELinux <selinux@tycho.nsa.gov>, Linux Containers <containers@lists.osdl.org>, Alexey Dobriyan <adobriyan@gmail.com>, Andrew Morgan <morgan@kernel.org>
List-Id: containers.vger.kernel.org



Serge E. Hallyn wrote:
> Quoting Stephen Smalley (sds@epoch.ncsc.mil):
>> On Fri, 2009-06-19 at 20:32 -0500, Serge E. Hallyn wrote:

[...]

>> Also, where do we get to veto attempts to checkpoint the task in the
>> first place?  If ptrace, I think we'd want it treated as a
>> PTRACE_MODE_ATTACH (also used for /proc/pid/mem) rather than just
>> PTRACE_MODE_READ (reading other /proc/pid info).
> 
> The checkpointing of ipc objects goes through an ipcperms(perm, S_IROTH)
> check in ipc/checkpoint (at top of
> http://git.ncl.cs.columbia.edu/?p=linux-cr.git;a=blob;f=ipc/checkpoint.c;h=88996e2b7abf328bd1b263400798ed5bd4924f48;hb=HEAD
> )
> 
> But yes, for the task itself we check PTRACE_MODE_READ (line 280 in
> http://git.ncl.cs.columbia.edu/?p=linux-cr.git;a=blob;f=checkpoint/checkpoint.c;h=a6dee4fb1085a47095f24443c48683a7fbc8ac59;hb=HEAD )
> I had thought that PTRACE_MODE_ATTACH implied the permission to
> actually modify the task.  If it also can imply a "very invasive" read 
> then changing it certainly seems right.

Hmmm... I was unaware of this:   http://lwn.net/Articles/282930/
So yes, probably need to change that.

Oren.

