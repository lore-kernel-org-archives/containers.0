From: Mike Snitzer <snitzer@gmail.com>
Subject: Re: [GIT PULL] nsfd fixes
Date: Tue, 21 Jun 2011 21:29:33 -0400
Message-ID: <BANLkTikkHsd4kLnHdtS7D8QGBQyFuYhFBg@mail.gmail.com>
References: <m162nyn8jd.fsf@fess.ebiederm.org> <BANLkTikq0XRkvkX6O5C2yKf6rRvMWciZpA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <BANLkTikq0XRkvkX6O5C2yKf6rRvMWciZpA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, linux-kernel@vger.kernel.org, Linux Containers <containers@lists.osdl.org>
List-Id: containers.vger.kernel.org

On Tue, Jun 21, 2011 at 9:25 PM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
> On Tue, Jun 21, 2011 at 3:07 PM, Eric W. Biederman
> <ebiederm@xmission.com> wrote:
>>
>> When looking over my namespace file descriptor code I realized I goo=
fed
>> in the implementation. =A0I missed the addition of d_set_d_op, and
>> painfully I badly placed the ptrace_may_read permission checks with =
the
>> result that the dcache could cache things and bypass the checks.
>>
>> The fixes are available at.
>> git://git.kernel.org/pub/scm/linux/kernel/git/ebiederm/linux-2.6-nsf=
d.git
>
> Why do you talk about nfsd fixes in both the repository name and in
> the subject line? This seems to have nothing to do with nfsd except i=
n
> the crazy sense of somebody trying to export /proc with nfs.
>
> Not pulled due to extreme confusion and craziness.

I had to read it a couple times too: nSFd not nFSd.

As in Name Space File Descriptors.
