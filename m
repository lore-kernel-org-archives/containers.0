Received: from mail.hallyn.com (mail.hallyn.com [178.63.66.53])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A532568
	for <containers@lists.linux.dev>; Tue, 30 Nov 2021 04:59:13 +0000 (UTC)
Received: by mail.hallyn.com (Postfix, from userid 1001)
	id D6FCCBDB; Mon, 29 Nov 2021 22:59:04 -0600 (CST)
Date: Mon, 29 Nov 2021 22:59:04 -0600
From: "Serge E. Hallyn" <serge@hallyn.com>
To: James Bottomley <James.Bottomley@HansenPartnership.com>
Cc: "Serge E. Hallyn" <serge@hallyn.com>,
	Christian Brauner <christian.brauner@ubuntu.com>,
	Stefan Berger <stefanb@linux.ibm.com>,
	linux-integrity@vger.kernel.org, containers@lists.linux.dev,
	Mimi Zohar <zohar@linux.ibm.com>,
	Dmitry Kasatkin <dmitry.kasatkin@gmail.com>,
	"Eric W . Biederman" <ebiederm@xmission.com>,
	krzysztof.struczynski@huawei.com,
	Roberto Sassu <roberto.sassu@huawei.com>,
	Michael Peters <mpeters@redhat.com>, Luke Hinds <lhinds@redhat.com>,
	Lily Sturmann <lsturman@redhat.com>,
	Patrick Uiterwijk <puiterwi@redhat.com>,
	Christian Brauner <christian@brauner.io>
Subject: Re: [RFC 3/3] ima: make the integrity inode cache per namespace
Message-ID: <20211130045904.GB32444@mail.hallyn.com>
References: <20211127164549.2571457-1-James.Bottomley@HansenPartnership.com>
 <20211127164549.2571457-4-James.Bottomley@HansenPartnership.com>
 <20211129045834.GB20606@mail.hallyn.com>
 <755446b10c8415fd469b814535c4a12964af3264.camel@HansenPartnership.com>
 <70b81e62-46af-9d39-3dcb-4cfbae645175@linux.ibm.com>
 <a74b18c1aee2b14426cc12e2fd336716c447f070.camel@HansenPartnership.com>
 <20211129142235.hez3ovtuj3rpscgm@wittgenstein>
 <afee2f0483271a6cdb1bc7b48b819a3ca2c4ceda.camel@HansenPartnership.com>
 <20211129153539.GA26325@mail.hallyn.com>
 <16e27be21e2886ba17298d94fdaff39236667890.camel@HansenPartnership.com>
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <16e27be21e2886ba17298d94fdaff39236667890.camel@HansenPartnership.com>
User-Agent: Mutt/1.9.4 (2018-02-28)

On Mon, Nov 29, 2021 at 11:44:35AM -0500, James Bottomley wrote:
> On Mon, 2021-11-29 at 09:35 -0600, Serge E. Hallyn wrote:
> > On Mon, Nov 29, 2021 at 09:46:55AM -0500, James Bottomley wrote:
> [...]
> > > Well, there's a reason it's an unpublished patch.  However, the
> > > more important point is that namespacing IMA requires discussion of
> > > certain points that we never seem to drive to a conclusion.  Using
> > > the akpm method, I propose simple patches that drive the
> > > discussion.  I think the points are:
> > > 
> > >    1. Should IMA be its own namespace or tied to the user
> > > namespace?  The previous patches all took the separate Namespace
> > > approach, but I think that should be reconsidered now keyrings are
> > > in the user namespace.
> > 
> > Well that purely depends on the needed scope.
> > 
> > The audit container identifier is a neat thing.  But it absolutely
> > must be settable, so seems to conflict with your needs.
> 
> I think not allowing duplicate entries for the lifetime of the log is
> required, which causes a problem since namespaces can die before this
> lifetime ends.  I think there is a nice security benefit in making it
> not user settable, but I don't think that's necessarily a requirement.
> 
> > Your patch puts an identifier on the user_namespace.  I'm not quite
> > sure, does that satisfy Stefan's needs?  A new ima ns if and only if
> > there is a new user ns?
> 
> Part of the problem is that IMA needs an admin user ... to be able to
> read the log and set the policy and, when we get to appraisal, set and
> read the keyrings.  IMA NS iff user ns satisfies this, but the
> minimalist in me then asks why not make them the same thing?
> 
> > I think you two need to get together and discuss the requirements,
> > and come back with a brief but very precise document explaining what
> > you need.
> 
> > Are you both looking at the same use case?  Who is consuming the
> > audit log, and to what end?  Container administrators?  Any time they
> > log in? How do they assure themselves that the securityfs file
> > they're reading hasn't been overmounted?
> 
> There are several different use cases.  I'm asking how I would use the
> IMA namespace for the unprivileged containers I usually set up by
> hand.  Stefan is looking at how docker/kubernetes would do it.  There's
> also the Huawei use case which is a sort of attestation for function as
> a service and there's the Red Hat use case for OpenShift.
> 
> However, the common denominator in all of these is they require a way
> to uniquely distinguish the containers, which is why the patch series I
> sent as an RFC starts that way.  If we can start with the common
> elements, we can build towards something that satisfies all the use
> cases ... and allow consensus to emerge as further patches are
> discussed.

The reason I asked this question in response to this patch is because
here I'm not picking at the userns->uuid, but rather it's the new linked
lists for the inode that feel wrong.  So if you can get what you need
some other way - maybe just "we opened all these files and got no
integrity failure messages", or a hash table keyed on (userns *, inode *)
instead of the linked lists to look up whether an inode has been measured,
or some userspace daemon to resubmit already logged approvals, which I
gather won't work for unpriv containers - that would be nice.

> Part of my problem is I don't really know what I need, I just want IMA
> namespaces to work easily for the unprivileged use case and I'll figure
> it out as I play with it ... but to do that I need something to start
> playing with.

But for that kind of research you use an out of tree patchset, not
speculative infrastructure in the kernel.  If that's what this
patchset is, then I'll (feel a little silly and) look over it with a
different set of eyes :)

> > I need to find a document to read about IMA's usage of PCRs.  For
> > namespacing, are you expecting each container to be hooked up to a
> > swtmp instance so they have their own PCR they can use?
> 
> That's one of the most complicated things of all: trying to attach a
> vTPM to store the local extensions and quote the IMA log in the
> namespace.  The Huawei patch doesn't have it, because they don't really
> need it (they just want global attestation to work), the IBM patches
> do.  I think there are many ways of attesting to the subset of the log
> in the namespace, so I don't think a vTPM is required.  I do, however,
> think it should be supported for the use cases that need it.
> 
> James
> 
