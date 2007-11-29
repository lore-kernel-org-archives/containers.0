From: Cedric Le Goater <clg@fr.ibm.com>
Subject: Re: [patch -mm 2/4] mqueue namespace : add unshare support
Date: Thu, 29 Nov 2007 11:28:15 +0100
Message-ID: <474E943F.40804@fr.ibm.com>
References: <20071128163728.177495768@fr.ibm.com>> <20071128164349.196734045@fr.ibm.com>> <474DA61B.5030301@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758891AbXK2K3G@vger.kernel.org>
In-Reply-To: <474DA61B.5030301@openvz.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Pavel Emelyanov <xemul@openvz.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Containers <containers@lists.osdl.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "Eric W. Biederman" <ebiederm@xmission.com>
List-Id: containers.vger.kernel.org


>> Index: 2.6.24-rc3-mm2/kernel/fork.c
>> ===================================================================
>> --- 2.6.24-rc3-mm2.orig/kernel/fork.c
>> +++ 2.6.24-rc3-mm2/kernel/fork.c
>> @@ -1004,6 +1004,13 @@ static struct task_struct *copy_process(
>>  	if ((clone_flags & CLONE_SIGHAND) && !(clone_flags & CLONE_VM))
>>  		return ERR_PTR(-EINVAL);
>>  
>> +	/*
>> +	 * mount namespace cannot be unshared when the mqueue
>> +	 * namespace is not
> 
> vice versa - mqueue namespace cannot be unshared when the mount one is not ;)

arg. yes :) 

Thanks !

C.


Signed-off-by: Cedric Le Goater <clg@fr.ibm.com>
---
 kernel/fork.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: 2.6.24-rc3-mm2/kernel/fork.c
===================================================================
--- 2.6.24-rc3-mm2.orig/kernel/fork.c
+++ 2.6.24-rc3-mm2/kernel/fork.c
@@ -1005,7 +1005,7 @@ static struct task_struct *copy_process(
                return ERR_PTR(-EINVAL);
 
        /*
-        * mount namespace cannot be unshared when the mqueue
+        * mqueue namespace cannot be unshared when the mount
         * namespace is not
         */
        if ((clone_flags & CLONE_NEWMQ) && !(clone_flags & CLONE_NEWNS))
