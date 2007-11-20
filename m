From: Andrew Morgan <morgan@kernel.org>
Subject: Re: [PATCH 1/1] capabilities: introduce per-process capability	bounding
 set (v8)
Date: Mon, 19 Nov 2007 21:37:03 -0800
Message-ID: <4742727F.6030104@kernel.org>
References: <20071119212519.GA23178@sergelap.austin.ibm.com> <47425727.10702@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <47425727.10702@kernel.org>
Sender: linux-security-module-owner@vger.kernel.org
To: "Serge E. Hallyn" <serue@us.ibm.com>
Cc: Chris Wright <chrisw@sous-sol.org>, casey@schaufler-ca.com, Andrew Morton <akpm@google.com>, Stephen Smalley <sds@tycho.nsa.gov>, KaiGai Kohei <kaigai@kaigai.gr.jp>, James Morris <jmorris@namei.org>, linux-security-module@vger.kernel.org, Linux Containers <containers@lists.osdl.org>
List-Id: containers.vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Andrew Morgan wrote:
>> +	current->cap_effective = cap_intersect(current->cap_effective,
>> +		current->cap_bset);
>> +	current->cap_permitted = cap_intersect(current->cap_permitted,
>> +		current->cap_bset);
>> +	current->cap_inheritable = cap_intersect(current->cap_inheritable,
>> +		current->cap_bset);
> 
> You might want to replace the above three lines with a restriction
> elsewhere on what CAP_SETPCAP can newly set in
> commoncap.c:cap_capset_check().
> 
> That is, CAP_SETPCAP permits the current process to raise 'any' pI
> capability. I suspect that you'll want to prevent raising any bits not
> masked by this:
> 
>    pI' & ~(pI | (pP & cap_bset)).

On second thoughts, I really meant this:

diff --git a/security/commoncap.c b/security/commoncap.c
index 302e8d0..b28c0c1 100644
- --- a/security/commoncap.c
+++ b/security/commoncap.c
@@ -133,6 +133,12 @@ int cap_capset_check (struct task_struct *target,
kernel_ca                /* incapable of using this inheritable set */
                return -EPERM;
        }
+       if (!cap_issubset(*inheritable,
+                         cap_combine(target->cap_inheritable,
+                                     current->cap_bset))) {
+               /* no new pI capabilities outside bounding set */
+               return -EPERM;
+       }

        /* verify restrictions on target's new Permitted set */
        if (!cap_issubset (*permitted,

Cheers

Andrew
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.6 (GNU/Linux)

iD8DBQFHQnJ8QheEq9QabfIRAl2rAJ4jH+l36N1+cHV+1A3DJpXs+UNsFgCgkg8H
xOU/7dCrEq02xk9EgcRarg0=
=FbqU
-----END PGP SIGNATURE-----
