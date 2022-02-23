Received: from mail.hallyn.com (mail.hallyn.com [178.63.66.53])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 849C766C8
	for <containers@lists.linux.dev>; Wed, 23 Feb 2022 17:59:57 +0000 (UTC)
Received: by mail.hallyn.com (Postfix, from userid 1001)
	id 60528821; Wed, 23 Feb 2022 11:51:21 -0600 (CST)
Date: Wed, 23 Feb 2022 11:51:21 -0600
From: "Serge E. Hallyn" <serge@hallyn.com>
To: Stefan Berger <stefanb@linux.ibm.com>
Cc: "Serge E. Hallyn" <serge@hallyn.com>, linux-integrity@vger.kernel.org,
	zohar@linux.ibm.com, christian.brauner@ubuntu.com,
	containers@lists.linux.dev, dmitry.kasatkin@gmail.com,
	ebiederm@xmission.com, krzysztof.struczynski@huawei.com,
	roberto.sassu@huawei.com, mpeters@redhat.com, lhinds@redhat.com,
	lsturman@redhat.com, puiterwi@redhat.com, jejb@linux.ibm.com,
	jamjoom@us.ibm.com, linux-kernel@vger.kernel.org,
	paul@paul-moore.com, rgb@redhat.com,
	linux-security-module@vger.kernel.org, jmorris@namei.org,
	Denis Semakin <denis.semakin@huawei.com>
Subject: Re: [PATCH v10 12/27] ima: Define mac_admin_ns_capable() as a
 wrapper for ns_capable()
Message-ID: <20220223175121.GA10272@mail.hallyn.com>
References: <20220201203735.164593-1-stefanb@linux.ibm.com>
 <20220201203735.164593-13-stefanb@linux.ibm.com>
 <20220205055826.GA15072@mail.hallyn.com>
 <9c8a09d6-6373-c8c2-c8ff-2b4c3f92ddf1@linux.ibm.com>
 <cb94bd18-2d6c-772f-b16e-a4778480258b@linux.ibm.com>
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <cb94bd18-2d6c-772f-b16e-a4778480258b@linux.ibm.com>
User-Agent: Mutt/1.9.4 (2018-02-28)

On Mon, Feb 07, 2022 at 01:43:31PM -0500, Stefan Berger wrote:
> 
> On 2/6/22 12:20, Stefan Berger wrote:
> > 
> > On 2/5/22 00:58, Serge E. Hallyn wrote:
> > > On Tue, Feb 01, 2022 at 03:37:20PM -0500, Stefan Berger wrote:
> > > > Define mac_admin_ns_capable() as a wrapper for the combined
> > > > ns_capable()
> > > > checks on CAP_MAC_ADMIN and CAP_SYS_ADMIN in a user namespace. Return
> > > > true on the check if either capability or both are available.
> > > > 
> > > > Use mac_admin_ns_capable() in place of capable(SYS_ADMIN). This
> > > > will allow
> > > > an IMA namespace to read the policy with only CAP_MAC_ADMIN, which has
> > > > less privileges than CAP_SYS_ADMIN.
> > > > 
> > > > Signed-off-by: Denis Semakin <denis.semakin@huawei.com>
> > > > Signed-off-by: Stefan Berger <stefanb@linux.ibm.com>
> > > > ---
> > > >   include/linux/capability.h      | 6 ++++++
> > > >   security/integrity/ima/ima.h    | 6 ++++++
> > > >   security/integrity/ima/ima_fs.c | 5 ++++-
> > > >   3 files changed, 16 insertions(+), 1 deletion(-)
> > > > 
> > > > diff --git a/include/linux/capability.h b/include/linux/capability.h
> > > > index 65efb74c3585..991579178f32 100644
> > > > --- a/include/linux/capability.h
> > > > +++ b/include/linux/capability.h
> > > > @@ -270,6 +270,12 @@ static inline bool
> > > > checkpoint_restore_ns_capable(struct user_namespace *ns)
> > > >           ns_capable(ns, CAP_SYS_ADMIN);
> > > >   }
> > > >   +static inline bool mac_admin_ns_capable(struct user_namespace *ns)
> > > > +{
> > > > +    return ns_capable(ns, CAP_MAC_ADMIN) ||
> > > > +        ns_capable(ns, CAP_SYS_ADMIN);
> > > Do you care about audit warnings?  If the task has CAP_SYS_ADMIN but
> > > not CAP_MAC_ADMIN, is it desirable that selinux_capable() will audit the
> > > CAP_MAC_ADMIN failure?
> > 
> > Good point.  I will switch both to ns_capable_noaudit() so that the user
> > cannot provoke unnecessary audit message.
> 
> Actually,  I will only change the MAC_ADMIN to not do auditing and not
> change the auditing behavior related to SYS_ADMIN.

Right, that makes the most sense.
