Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [216.205.24.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 849B171
	for <containers@lists.linux.dev>; Mon, 10 May 2021 13:03:04 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1620651783;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=yNWhrPlkJKK5ocPGOthWztDmW7h7bO5ggRQNH2LmKSE=;
	b=jU97vVzuQ433Yxly4ueVrDCxVnuiyJtKG3pgmqWHTVJ0pcLoBJOFOVL8yoGtph9MzWTRSg
	U5XGYbfa3L2RfSJ+6hywjUzGTlfaHvvQzHpFu9V1mOnzQNthXhhuzTYKqEbVO+W4fe6GnA
	YtKpDqo2TCgFY5XVly7ieRELjn+doKk=
Received: from mimecast-mx01.redhat.com (mimecast-mx01.redhat.com
 [209.132.183.4]) (Using TLS) by relay.mimecast.com with ESMTP id
 us-mta-101-u1JenIKgOJCBWzps-7kMaA-1; Mon, 10 May 2021 09:03:00 -0400
X-MC-Unique: u1JenIKgOJCBWzps-7kMaA-1
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mimecast-mx01.redhat.com (Postfix) with ESMTPS id 9927B107ACF5;
	Mon, 10 May 2021 13:02:55 +0000 (UTC)
Received: from localhost (ovpn-115-83.ams2.redhat.com [10.36.115.83])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 8983D61094;
	Mon, 10 May 2021 13:02:53 +0000 (UTC)
From: Giuseppe Scrivano <gscrivan@redhat.com>
To: "Serge E. Hallyn" <serge@hallyn.com>
Cc: Snaipe <snaipe@arista.com>,  alexander@mihalicyn.com,
  christian.brauner@ubuntu.com, Linux Containers
 <containers@lists.linux.dev>,  cyphar@cyphar.com,  ebiederm@xmission.com,
  geofft@ldpreload.com,  jcsible@cert.org,  josh@joshtriplett.org,
  keescook@chromium.org,  linux-kernel@vger.kernel.org,
  luto@amacapital.net,  mic@digikod.net,  mpatel@redhat.com,
  ptikhomirov@virtuozzo.com,  sargun@sargun.me,  stgraber@ubuntu.com,
  vgoyal@redhat.com,  watl@google.com
Subject: Re: LPC 2020 Hackroom Session: summary and next steps for isolated
 user namespaces
References: <87ft6act3c.fsf@redhat.com>
	<20210421172714.912119-1-snaipe@arista.com>
	<87h7jyvfsm.fsf@redhat.com> <20210507133703.GB22450@mail.hallyn.com>
Date: Mon, 10 May 2021 15:02:51 +0200
In-Reply-To: <20210507133703.GB22450@mail.hallyn.com> (Serge E. Hallyn's
	message of "Fri, 7 May 2021 08:37:03 -0500")
Message-ID: <87cztyhhc4.fsf@redhat.com>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/27.2 (gnu/linux)
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: text/plain
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12

Hi Serge,

"Serge E. Hallyn" <serge@hallyn.com> writes:

> On Thu, Apr 22, 2021 at 11:18:01AM +0200, Giuseppe Scrivano wrote:
>> Snaipe <snaipe@arista.com> writes:
>> 
>> > "Giuseppe Scrivano" <gscrivan@redhat.com> writes:
>> >>>> >> instead of a prctl, I've added a new mode to /proc/PID/setgroups that
>> >>>> >> allows setgroups in a userns locking the current gids.
>> >>>> >> 
>> >>>> >> What do you think about using /proc/PID/setgroups instead of a new
>> >>>> >> prctl()?
>> >>>> >
>> >>>> > It's better than not having it, but two concerns -
>> >>>> >
>> >>>> > 1. some userspace, especially testsuites, could become confused by the fact
>> >>>> > that they can't drop groups no matter how hard they try, since these will all
>> >>>> > still show up as regular groups.
>> >>>> 
>> >>>> I forgot to send a link to a second patch :-) that completes the feature:
>> >>>> https://github.com/giuseppe/linux/commit/1c5fe726346b216293a527719e64f34e6297f0c2
>> >>>> 
>> >>>> When the new mode is used, the gids that are not known in the userns do
>> >>>> not show up in userspace.
>> >>>
>> >>> Ah, right - and of course those gids better not be mapped into the namespace :)
>> >>>
>> >>> But so, this is the patch you said you agreed was not worth the extra
>> >>> complexity?
>> >>
>> >> yes, these two patches are what looked too complex at that time.  The
>> >> problem still exists though, we could perhaps reconsider if the
>> >> extra-complexity is acceptable to address it.
>> >
>> > Hey Folks, sorry for necro-bumping, but I've found this discussion
>> > while searching for this specific issue, and it seems like the most
>> > recent relevant discussion on the matter. I'd like to chime in with
>> > our personal experience.
>> >
>> > We have a tool[1] that allows unprivileged use of namespaces
>> > (when using a userns, which is the default).
>> >
>> > The primary use-case of said tool is lightweight containerization,
>> > but we're also using it for other mundane usages, like a better
>> > substitute for fakeroot to build and package privileged software
>> > (e.g. sudo or ping, which needs to be installed with special
>> > capabilities) unprivileged, or to copy file trees that are owned by
>> > the user or sub-ids.
>> >
>> > For the first use-case, it's always safe to drop unmapped groups,
>> > because the target rootfs is always owned by the user or its sub-ids.
>> >
>> > For the other use-cases, this is more problematic, as you're all
>> > well-aware of. Our position right now is that the tool will always
>> > allow setgroups in user namespace, and that it's not safe to use on
>> > systems that rely on negative access groups.
>> >
>> > I think that something that's not mentioned is that if a user setgroups
>> > to a fixed list of subgids, dropping all unmapped gids, they don't just
>> > gain the ability to access these negative-access files, they also lose
>> > legitimate access to files that their unmapped groups allow them to
>> > access. This is fine for our first use-case, but a bit surprising for
>> > the second one -- and since setgroups never lets us keep unmapped gids,
>> > we have no way to keep these desired groups.
>> >
>> > From a first glance, a sysctl that explicitly controls that would not
>> > address the above problem, but keeping around the original group list
>> > of the owner of the user ns would have the desired semantics.
>> >
>> > Giuseppe's patch seems to address this use case, which would personally
>> > make me very happy.
>> >
>> > [1]: https://github.com/aristanetworks/bst
>> 
>> thanks for the feedback.  We are still facing the issue with rootless
>> Podman, and these patches (listed here so you won't need to dig into archives):
>> 
>> https://github.com/giuseppe/linux/commit/7e0701b389c497472d11fab8570c153a414050af
>> https://github.com/giuseppe/linux/commit/1c5fe726346b216293a527719e64f34e6297f0c2
>> 
>> would solve the issue for us as well and we can use setgroups within a
>> user namespace in a safe way.
>> 
>> Any comments on this approach?  Could we move forward with it?
>
> Can you send these to lkml?  I'll have to go back through our previous
> discussions, but offhand this looks good to me.

I've just sent them to lkml.

Regards,
Giuseppe

