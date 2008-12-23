From: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
Subject: Re: [RFC][PATCH 0/6][v3] Container-init signal semantics
Date: Mon, 22 Dec 2008 18:12:17 -0800
Message-ID: <20081223021217.GA14957@us.ibm.com>
References: <20081221005106.GA4912@us.ibm.com> <m1wsds5vij.fsf@frodo.ebiederm.org> <20081222194737.GC9085@us.ibm.com> <m1aban68i3.fsf@frodo.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755959AbYLWCNy@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <m1aban68i3.fsf@frodo.ebiederm.org>
Sender: linux-kernel-owner@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: oleg@redhat.com, roland@redhat.com, bastian@waldi.eu.org, daniel@hozac.com, xemul@openvz.org, containers@lists.osdl.org, linux-kernel@vger.kernel.org, sukadev@us.ibm.com
List-Id: containers.vger.kernel.org

Eric W. Biederman [ebiederm@xmission.com] wrote:
| I haven't dug in too deep but right now my concern are user space semantics,
| I don't want to wind up with something ugly there because we can not change
| it later.

The one restriction we are imposing is that SIGINT, SIGTERM etc will not
currently kill containter-inits. Only SIGKILL will.  But that is good point.
Maybe we should document that as a limitation we may remove in the future ? 
i.e. Its not a feature that container-inits should rely on.  Like sysV init,
container-init should still SIG_IGN all unhandled signals. If they don't,
they may break in the future.

| 
| So if we can write a description of what happens to signals to cinit
| that is right 100% of the time.  Something we can write a test case
| for that tests all of the corner cases and it always get the same
| results. I am happy.

Yes, I believe we can say that SIGKILL/SIGSTOP from parent are always
delivered and no fatal signal from same ns is.

| 
| I don't mind dropping signals early as an optimization, but if it
| is just an optimization we can't count on it in cinit.

Yes, you have a point. It started out as an optimization, but unwanted
signals are either ignored or dropped _always_ (or we have a bug).

| 
| So I would rather deliver less and make user space deal with it,
| then deliver more cause problems for user space.

The user-semantics appear to be clean now.
