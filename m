From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [PATCH 5/8] groups: allow compilation on s390x
Date: Tue, 26 May 2009 18:17:41 -0500
Message-ID: <20090526231741.GA19730@us.ibm.com>
References: <20090526173242.GA13757@us.ibm.com> <20090526173344.GE13991@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090526173344.GE13991@us.ibm.com>
Sender: linux-security-module-owner@vger.kernel.org
To: Oren Laadan <orenl@cs.columbia.edu>
Cc: Linux Containers <containers@lists.osdl.org>, David Howells <dhowells@redhat.com>, Alexey Dobriyan <adobriyan@gmail.com>, linux-security-module@vger.kernel.org
List-Id: containers.vger.kernel.org

Quoting Serge E. Hallyn (serue@us.ibm.com):
> Signed-off-by: Serge E. Hallyn <serue@us.ibm.com>
> ---
>  kernel/groups.c |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
> 
> diff --git a/kernel/groups.c b/kernel/groups.c
> index 1b95b2f..14ebc6a 100644
> --- a/kernel/groups.c
> +++ b/kernel/groups.c
> @@ -1,6 +1,7 @@
>  /*
>   * Supplementary group IDs
>   */
> +#include <linux/init.h>
>  #include <linux/cred.h>
>  #include <linux/module.h>
>  #include <linux/slab.h>
> -- 
> 1.6.1

As noted by Alexey, this is wrong, and the prob was
actually fixed by the following patch he'd also sent
last friday, so please replace this patch with the
following:

From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 01/38] cred: #include init.h in cred.h

cred.h can't be included as first header because it uses __init and
doesn't include init.h which is enough to break compilation on at least
ia64.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---
 include/linux/cred.h |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/include/linux/cred.h b/include/linux/cred.h
index 3282ee4..4fa9996 100644
--- a/include/linux/cred.h
+++ b/include/linux/cred.h
@@ -13,6 +13,7 @@
 #define _LINUX_CRED_H
 
 #include <linux/capability.h>
+#include <linux/init.h>
 #include <linux/key.h>
 #include <asm/atomic.h>
 
-- 
1.5.6.5

_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linux-foundation.org/mailman/listinfo/containers
