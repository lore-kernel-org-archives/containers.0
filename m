From: Casey Schaufler <casey@schaufler-ca.com>
Subject: Re: [PATCH 0/8] a start to credentials c/r
Date: Tue, 26 May 2009 20:05:39 -0700
Message-ID: <4A1CAE03.7090005@schaufler-ca.com>
References: <20090526173242.GA13757@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20090526173242.GA13757@us.ibm.com>
Sender: linux-security-module-owner@vger.kernel.org
To: "Serge E. Hallyn" <serue@us.ibm.com>
Cc: Oren Laadan <orenl@cs.columbia.edu>, Linux Containers <containers@lists.osdl.org>, David Howells <dhowells@redhat.com>, Alexey Dobriyan <adobriyan@gmail.com>, linux-security-module@vger.kernel.org
List-Id: containers.vger.kernel.org

Serge E. Hallyn wrote:
> Following is the next version of the credentials c/r patchset,
> on top of the c/r patchset at
> git://git.ncl.cs.columbia.edu/pub/git/linux-cr.git
>
> It implements checkpoint and restart of user, user namespaces,
> groups, supplementary groups, and struct cred.
>
> There is a question as to what to do about LSM data at
> restart.  Right now I'm ignoring it, which means that
> prepare_creds() should ensure that the restart tasks get
> the context of the task calling sys_restart().  I
> suspect the right thing to do is to add two new LSM
> hooks, one which checks current's authorization to
> restart from the checkpoint file,

How would that work? Based on information in the file?
You have to assume that some number of checkpoint files
have been hand written by Elbonian ne'er do wells.

>  and one which determines
> the task->cred->security filed based upon any of:
> 	1. current_security() of the task calling sys_restart()
> 	2. the task->cred->security checkpointed in the ckpt file
> 	3. the ->security of the checkpoint file
>   

For Smack the correct behavior would be:

    1. for sys_restart() callers without CAP_MAC_ADMIN
    2. for sys_restart() callers with CAP_MAC_ADMIN
    3. never

sys_restart() callers running with CAP_MAC_ADMIN would have to be
very very careful about the files they restart. But that's nothing
new in the MAC world.

> Oren, I think this version has all the changes you asked
> for except for restoring cred info for sysvipc.
>
> thanks,
> -serge
> --
> To unsubscribe from this list: send the line "unsubscribe linux-security-module" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>
>   
