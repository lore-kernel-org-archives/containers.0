From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [GIT PULL] nsfd fixes
Date: Tue, 21 Jun 2011 18:25:02 -0700
Message-ID: <BANLkTikq0XRkvkX6O5C2yKf6rRvMWciZpA@mail.gmail.com>
References: <m162nyn8jd.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <m162nyn8jd.fsf@fess.ebiederm.org>
Sender: linux-kernel-owner@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: linux-kernel@vger.kernel.org, Linux Containers <containers@lists.osdl.org>
List-Id: containers.vger.kernel.org

On Tue, Jun 21, 2011 at 3:07 PM, Eric W. Biederman
<ebiederm@xmission.com> wrote:
>
> When looking over my namespace file descriptor code I realized I goof=
ed
> in the implementation. =A0I missed the addition of d_set_d_op, and
> painfully I badly placed the ptrace_may_read permission checks with t=
he
> result that the dcache could cache things and bypass the checks.
>
> The fixes are available at.
> git://git.kernel.org/pub/scm/linux/kernel/git/ebiederm/linux-2.6-nsfd=
=2Egit

Why do you talk about nfsd fixes in both the repository name and in
the subject line? This seems to have nothing to do with nfsd except in
the crazy sense of somebody trying to export /proc with nfs.

Not pulled due to extreme confusion and craziness.

                   Linus
