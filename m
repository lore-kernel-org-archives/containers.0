From: "Serge E. Hallyn" <serge@hallyn.com>
Subject: Re: container support in DazukoFS
Date: Sat, 3 Jul 2010 16:13:16 -0500
Message-ID: <20100703211316.GA1646@hallyn.com>
References: <87tyogde9l.fsf@lonestar.fn.ogness.net>
 <m1vd8wr2qb.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <m1vd8wr2qb.fsf@fess.ebiederm.org>
Sender: linux-fsdevel-owner@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: John Ogness <dazukolist3@ogness.net>, Linux Containers <containers@lists.osdl.org>, linux-fsdevel@vger.kernel.org, dazuko-devel@nongnu.org
List-Id: containers.vger.kernel.org

Quoting Eric W. Biederman (ebiederm@xmission.com):
> John Ogness <dazukolist3@ogness.net> writes:
> For the mount namespace which sounds like you primarily care about the
> APIs are:
> clone( ... CLONE_NEWNS ... )
> unshare( CLONE_NEWNS )
> mount( ... )
> chroot( ... )

and pivot_root

> They have been in the kernel since at least 2.5.early.  If you are doing
> interesting things with filesystems and you don't understand those APIs
> I don't see how you can possibly create correct code.
> 
> 
> Eric
> _______________________________________________
> Containers mailing list
> Containers@lists.linux-foundation.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
