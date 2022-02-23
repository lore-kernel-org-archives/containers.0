Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 67F437A
	for <containers@lists.linux.dev>; Wed, 23 Feb 2022 08:14:28 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 6C364C340E7;
	Wed, 23 Feb 2022 08:14:23 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1645604068;
	bh=ORM81g/BJs6DqcF1RJUtYk0o42tX/xtNTRjiaCRrSJI=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=uT6lcksV5+Ne5ixwr7lmetDdy+xY58hO5AeCSF+CW4YCneaY9TnMgC0DFV4uRDtD5
	 /pyXqmJQDAuI0pJgik5QK/0FH/z2/Xx1EVBKgN+YveRiw8k6UKW8sb6qmoLfnrJlht
	 D7xFLTXgyaY5J/04jXlaqkDZIotqjDNS18I0gmLurZ/1ngWVoMuehiBucYNprQxpIx
	 r8unlVaTrbmeWKNzf87FSbKFemUgweeScb7ZXbpkFCaB7/asmcpGKv0aPWz6rK6hfo
	 2FtNq8lKvIhcOInfBHsm/cFZKPBmcEoW2dPHuxTIKJ9jFvPpbW9kDPTArtHCKbmV7v
	 tQOAJzmr0QYaA==
Date: Wed, 23 Feb 2022 09:14:20 +0100
From: Christian Brauner <brauner@kernel.org>
To: Mimi Zohar <zohar@linux.ibm.com>
Cc: Stefan Berger <stefanb@linux.ibm.com>, linux-integrity@vger.kernel.org,
	serge@hallyn.com, containers@lists.linux.dev,
	dmitry.kasatkin@gmail.com, ebiederm@xmission.com,
	krzysztof.struczynski@huawei.com, roberto.sassu@huawei.com,
	mpeters@redhat.com, lhinds@redhat.com, lsturman@redhat.com,
	puiterwi@redhat.com, jejb@linux.ibm.com, jamjoom@us.ibm.com,
	linux-kernel@vger.kernel.org, paul@paul-moore.com, rgb@redhat.com,
	linux-security-module@vger.kernel.org, jmorris@namei.org,
	James Bottomley <James.Bottomley@HansenPartnership.com>
Subject: Re: [PATCH v10 22/27] securityfs: Extend securityfs with namespacing
 support
Message-ID: <20220223081420.7mthf3rfxb3n5gvs@wittgenstein>
References: <20220201203735.164593-1-stefanb@linux.ibm.com>
 <20220201203735.164593-23-stefanb@linux.ibm.com>
 <177baf827c4dbf9a225b14552725360066af6471.camel@linux.ibm.com>
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <177baf827c4dbf9a225b14552725360066af6471.camel@linux.ibm.com>

On Tue, Feb 22, 2022 at 08:48:47PM -0500, Mimi Zohar wrote:
> On Tue, 2022-02-01 at 15:37 -0500, Stefan Berger wrote:
> > Enable multiple instances of securityfs by keying each instance with a
> > pointer to the user namespace it belongs to.
> > 
> > Since we do not need the pinning of the filesystem for the virtualization
> 
> ^namespacing case
> 
> > case, limit the usage of simple_pin_fs() and simpe_release_fs() to the
> 
> ^simple_release_fs
> 
> > case when the init_user_ns is active. This simplifies the cleanup for the
> > virtualization case where usage of securityfs_remove() to free dentries
> 
> ^namespacing 
> 
> > is therefore not needed anymore.
> > 
> > For the initial securityfs, i.e. the one mounted in the host userns mount,
> > nothing changes. The rules for securityfs_remove() are as before and it is
> > still paired with securityfs_create(). Specifically, a file created via
> > securityfs_create_dentry() in the initial securityfs mount still needs to
> > be removed by a call to securityfs_remove(). Creating a new dentry in the
> > initial securityfs mount still pins the filesystem like it always did.
> > Consequently, the initial securityfs mount is not destroyed on
> > umount/shutdown as long as at least one user of it still has dentries that
> > it hasn't removed with a call to securityfs_remove().
> > 
> > Prevent mounting of an instance of securityfs in another user namespace
> > than it belongs to. Also, prevent accesses to files and directories by
> > a user namespace that is neither the user namespace it belongs to
> > nor an ancestor of the user namespace that the instance of securityfs
> > belongs to. Do not prevent access if securityfs was bind-mounted and
> > therefore the init_user_ns is the owning user namespace.
> > 
> > Suggested-by: Christian Brauner <brauner@kernel.org>
> > Signed-off-by: Stefan Berger <stefanb@linux.ibm.com>
> > Signed-off-by: James Bottomley <James.Bottomley@HansenPartnership.com>
> 
> Christian, I understand that "[PATCH v10 23/27] ima: Setup securityfs
> for IMA namespace" needs to be deferred, but is there a reason for
> deferring  "[PATCH v10 22/27] securityfs: Extend securityfs with
> namespacing support"?   As the securityfs patches are really
> independent of IMA namespacing, I would have thought  "[PATCH v10
> 04/27] securityfs: rework dentry creation" and this patch should be co-
> located at the beginning of the patch set.

It felt more natural to me to defer it until the end but I have no
strong thoughts on this as of right now. Since Stefan has mentioned
moving this earlier already himself and you seem to agree as well, feel
free to do so.
