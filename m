Return-Path: <SRS0=50w+=DC=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 07688C4363D
	for <containers@archiver.kernel.org>; Fri, 25 Sep 2020 08:13:23 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 20313207C4
	for <containers@archiver.kernel.org>; Fri, 25 Sep 2020 08:13:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 20313207C4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ubuntu.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by fraxinus.osuosl.org (Postfix) with ESMTP id 6E39686C08;
	Fri, 25 Sep 2020 08:13:21 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id KPcDIZjQ4wBX; Fri, 25 Sep 2020 08:13:20 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by fraxinus.osuosl.org (Postfix) with ESMTP id B78C686BEF;
	Fri, 25 Sep 2020 08:13:20 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id A562CC0859;
	Fri, 25 Sep 2020 08:13:20 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
 by lists.linuxfoundation.org (Postfix) with ESMTP id DB4D1C0051
 for <containers@lists.linux-foundation.org>;
 Fri, 25 Sep 2020 08:13:18 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by whitealder.osuosl.org (Postfix) with ESMTP id D77898545E
 for <containers@lists.linux-foundation.org>;
 Fri, 25 Sep 2020 08:13:18 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id fdNT331iwmiL
 for <containers@lists.linux-foundation.org>;
 Fri, 25 Sep 2020 08:13:17 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from youngberry.canonical.com (youngberry.canonical.com
 [91.189.89.112])
 by whitealder.osuosl.org (Postfix) with ESMTPS id C181484EE9
 for <containers@lists.linux-foundation.org>;
 Fri, 25 Sep 2020 08:13:17 +0000 (UTC)
Received: from ip5f5af089.dynamic.kabel-deutschland.de ([95.90.240.137]
 helo=wittgenstein) by youngberry.canonical.com with esmtpsa
 (TLS1.2:ECDHE_RSA_AES_128_GCM_SHA256:128) (Exim 4.86_2)
 (envelope-from <christian.brauner@ubuntu.com>)
 id 1kLiqq-0004AR-A0; Fri, 25 Sep 2020 08:13:08 +0000
Date: Fri, 25 Sep 2020 10:13:07 +0200
From: Christian Brauner <christian.brauner@ubuntu.com>
To: Alban Crequy <alban.crequy@gmail.com>
Subject: Re: Use cases for multiple uid mapping?
Message-ID: <20200925081307.bjetfa4afk5c3csc@wittgenstein>
References: <87zh6eiyv7.fsf@x220.int.ebiederm.org>
 <20200901060631.GA5193@mail.hallyn.com>
 <871rjleefo.fsf@x220.int.ebiederm.org>
 <CAMXgnP4WLJt+k_R8E9cbfCatV5Sevqh=uYPK9VRB0SYTY=QmtA@mail.gmail.com>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <CAMXgnP4WLJt+k_R8E9cbfCatV5Sevqh=uYPK9VRB0SYTY=QmtA@mail.gmail.com>
Cc: Linux Containers <containers@lists.linux-foundation.org>,
 "Eric W. Biederman" <ebiederm@xmission.com>
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

On Thu, Sep 24, 2020 at 07:09:21PM +0200, Alban Crequy wrote:
> On Tue, 1 Sep 2020 at 16:53, Eric W. Biederman <ebiederm@xmission.com> wrote:
> >
> > "Serge E. Hallyn" <serge@hallyn.com> writes:
> >
> > > On Fri, Aug 28, 2020 at 10:17:16AM -0500, Eric W. Biederman wrote:
> > >>
> > >> We had a discussion in the hackroom at LPC talking about use cases for
> > >> a shiftfs style setup where there are different mappings of uids to
> > >> disk.
> > >>
> > >> In the discussion we had a couple of ideas of kernel developments
> > >> we should look at that address some of these.
> > >>
> > >> - Fix rlimits in user namespaces (This potentially allows multiple
> > >>   containers to run with the same userids simplifying the mapping
> > >>   problem).
> > >>
> > >> - Look at extending kuid_t to 64bits and using the highbits to
> > >>   implement uids that are private to user namespaces and don't
> > >>   map out.
> > >>
> > >> - Look at ways for allowing setgroups unprivileged.
> > >>
> > >>
> > >> Together this has the potential that the existing uid & gid mappings
> > >> will be able to function the same as the proposed fusid mappings. Fingers crossed.
> > >>
> > >>
> > >> I had some problems with audio and a lot of people were talking
> > >> quickly.  So I did not manage to capture everyone's use cases.   And I
> > >> definitely was not able to see how everyone's use cases interacted with
> > >> the changes we are looking at.
> > >>
> > >> I know for certain I missed Serge's usecase (apologies).
> > >>
> > >> Can people follow up to this and report their use cases?
> > >
> > > Sorry - I'll do so later this week.
> >
> > Thank you.
> >
> > I know we have the OCI use case of overlayfs and sharing storage
> > between containers.
> 
> Is there a description of this use case, and ideas of possible solutions?
> 
> There was a use case that was brought to a recent Kubernetes sig-node
> meeting, but I am not sure it is the same one, so I'll describe this
> one.
> 
> We're working to enable user namespaces in Kubernetes with two possible setups:
> 1. Each Kubernetes pod has its own userns but with the same user id
> mapping (to make it easy to manage shared volumes)
> 2. Each Kubernetes pod has its own userns with non-overlapping user id
> mapping (providing additional isolation between pods)
> 
> Pods could be executed with a Kubernetes sidecar such as Envoy,
> meaning that if there are 'n' pods running on a node, there will be
> 'n' containers running the Envoy container image. In the second setup,
> each Envoy container will have a different user id mapping.
> 
> The Envoy container image will be snapshotted in as many copies, and
> each copy will be chown'ed appropriately for each non-overlapping user
> id mapping. Each copy will then be used as the lowerdir for the
> overlayfs rootfs of the container.
> 
> This results in a waste of disk space. Without user namespaces, we
> don't have this problem, since the same directory can be used as
> lowerdir for each container's overlayfs rootfs.
> 
> This is not specific to sidecars, but they exacerbate the problem.
> 
> I was not present in the Plumbers discussions, so I don't know if
> possible solutions were discussed. For example: could overlayfs get a

Hey Alban,

Tycho, Aleksa, Serge and I are collaborating on a patchset that intends
to cover all of these use-cases and that we hope to have ready for
review early after the next merge window.

Christian
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
