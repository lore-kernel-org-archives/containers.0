Return-Path: <SRS0=82Ss=DT=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8F352C433DF
	for <containers@archiver.kernel.org>; Mon, 12 Oct 2020 15:00:15 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id E93DB20870
	for <containers@archiver.kernel.org>; Mon, 12 Oct 2020 15:00:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E93DB20870
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=hallyn.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by whitealder.osuosl.org (Postfix) with ESMTP id 7768086B27;
	Mon, 12 Oct 2020 15:00:14 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id dQtAvZNzOFgW; Mon, 12 Oct 2020 15:00:12 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by whitealder.osuosl.org (Postfix) with ESMTP id 6ECCF86D69;
	Mon, 12 Oct 2020 15:00:12 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 5373CC07FF;
	Mon, 12 Oct 2020 15:00:12 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 0F850C0051
 for <containers@lists.linux-foundation.org>;
 Mon, 12 Oct 2020 15:00:11 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by hemlock.osuosl.org (Postfix) with ESMTP id EF9DA8762F
 for <containers@lists.linux-foundation.org>;
 Mon, 12 Oct 2020 15:00:10 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id Ueg-ZelwN6q1
 for <containers@lists.linux-foundation.org>;
 Mon, 12 Oct 2020 15:00:09 +0000 (UTC)
X-Greylist: from auto-whitelisted by SQLgrey-1.7.6
Received: from mail.hallyn.com (mail.hallyn.com [178.63.66.53])
 by hemlock.osuosl.org (Postfix) with ESMTPS id 095CA87359
 for <containers@lists.linux-foundation.org>;
 Mon, 12 Oct 2020 15:00:08 +0000 (UTC)
Received: by mail.hallyn.com (Postfix, from userid 1001)
 id 4A5A5CBF; Mon, 12 Oct 2020 10:00:06 -0500 (CDT)
Date: Mon, 12 Oct 2020 10:00:06 -0500
From: "Serge E. Hallyn" <serge@hallyn.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: Re: LPC 2020 Hackroom Session: summary and next steps for isolated
 user namespaces
Message-ID: <20201012150006.GA3503@mail.hallyn.com>
References: <20200830143959.rhosiunyz5yqbr35@wittgenstein>
 <20201010042606.GA30062@mail.hallyn.com>
 <20201011205306.GC17441@localhost>
 <CALCETrUZcHNwspz315KFvSPxtK8MmLUPfiN=hCBgx+wqeJe4+g@mail.gmail.com>
 <87h7r0qbqi.fsf@x220.int.ebiederm.org>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <87h7r0qbqi.fsf@x220.int.ebiederm.org>
User-Agent: Mutt/1.9.4 (2018-02-28)
Cc: Alexander Mihalicyn <alexander@mihalicyn.com>,
 Giuseppe Scrivano <gscrivan@redhat.com>,
 Joseph Christopher Sible <jcsible@cert.org>, Kees Cook <keescook@chromium.org>,
 LKML <linux-kernel@vger.kernel.org>,
 Linux Containers <containers@lists.linux-foundation.org>,
 Josh Triplett <josh@joshtriplett.org>, Geoffrey Thomas <geofft@ldpreload.com>,
 Vivek Goyal <vgoyal@redhat.com>, Andy Lutomirski <luto@kernel.org>,
 =?iso-8859-1?Q?Micka=EBl_Sala=FCn?= <mic@digikod.net>,
 Wat Lim <watl@google.com>, Mrunal Patel <mpatel@redhat.com>,
 Pavel Tikhomirov <ptikhomirov@virtuozzo.com>
X-BeenThere: containers@lists.linux-foundation.org
X-Mailman-Version: 2.1.15
Precedence: list
List-Id: Linux Containers <containers.lists.linuxfoundation.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>, 
 <mailto:containers-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers@lists.linux-foundation.org>
List-Help: <mailto:containers-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>, 
 <mailto:containers-request@lists.linux-foundation.org?subject=subscribe>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: containers-bounces@lists.linux-foundation.org
Sender: "Containers" <containers-bounces@lists.linux-foundation.org>

On Mon, Oct 12, 2020 at 12:01:09AM -0500, Eric W. Biederman wrote:
> Andy Lutomirski <luto@kernel.org> writes:
> 
> > On Sun, Oct 11, 2020 at 1:53 PM Josh Triplett <josh@joshtriplett.org> wrote:
> >>
> >> On Fri, Oct 09, 2020 at 11:26:06PM -0500, Serge E. Hallyn wrote:
> >> > > 3. Find a way to allow setgroups() in a user namespace while keeping
> >> > >    in mind the case of groups used for negative access control.
> >> > >    This was suggested by Josh Triplett and Geoffrey Thomas. Their idea was to
> >> > >    investigate adding a prctl() to allow setgroups() to be called in a user
> >> > >    namespace at the cost of restricting paths to the most restrictive
> >> > >    permission. So if something is 0707 it needs to be treated as if it's 0000
> >> > >    even though the caller is not in its owning group which is used for negative
> >> > >    access control (how these new semantics will interact with ACLs will also
> >> > >    need to be looked into).
> >> >
> >> > I should probably think this through more, but for this problem, would it
> >> > not suffice to add a new prevgroups grouplist to the struct cred, maybe
> >> > struct group_info *locked_groups, and every time an unprivileged task creates
> >> > a new user namespace, add all its current groups to this list?
> >>
> >> So, effectively, you would be allowed to drop permissions, but
> >> locked_groups would still be checked for restrictions?
> >>
> >> That seems like it'd introduce a new level of complexity (a new facet of
> >> permission) to manage. Not opposed, but it does seem more complex than
> >> just opting out of using groups for negative permissions.

Yeah, it would, but I basically hoped that we could catch most of this at
e.g. generic_permission(), and/or we could introduce a helper which
automatically adds a check for permission denied from locked_groups, so
it shouldn't be too wide-spread.  If it does end up showing up all over
the place, then that's a good reason not to do this.

> > Is there any context other than regular UNIX DAC in which groups can
> > act as negative permissions or is this literally just an issue for
> > files with a more restrictive group mode than other mode?
> 
> Just that.
> 
> The ideas kicked around in the conversation were some variant of having
> a sysctl that says "This system never uses groups for negative
> permissions".
> 
> It was also suggested that if the sysctl was set the the permission
> checks would be altered such that even if someone tried to set a
> negative permission, the more liberal permissions of other would be used
> instead.

So then this would touch all the same code points which the
locked_groups approach would have to touch?

> Given that creating /etc/subgid is effectively opting out of negative
> permissions already have a sysctl that says that upfront feels like a
> very clean solution.
> 
> Eric

That feels like a cop-out to me.  If some young admin at Roxxon Corp decides
she needs to run a container, so installs subuid package and sets that sysctl,
how does she know whether or not some previous admin, who has since retired and
did not keep good docs, set things up so that a negative acl is keeping nginx
from reading some supersecret doc?

Now personally I'm not a great believer in the negative acls so I think the
above is a very unlikely scenario, but if we're going to worry about it, then
we should worry about it :)

"Click this button if noone has ever used feature X on this server"

-serge
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
