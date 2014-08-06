From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [GIT PULL] namespace updates for v3.17-rc1
Date: Tue, 05 Aug 2014 23:30:59 -0700
Message-ID: <877g2mt9i4.fsf@x220.int.ebiederm.org>
References: <87fvhav3ic.fsf@x220.int.ebiederm.org>
	<20140806144643.45e5dab8@canb.auug.org.au>
	<87lhr2tcyx.fsf@x220.int.ebiederm.org>
	<20140806160608.218b6944@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20140806160608.218b6944-3FnU+UHB4dNDw9hX6IcOSA@public.gmane.org> (Stephen Rothwell's
	message of "Wed, 6 Aug 2014 16:06:08 +1000")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Stephen Rothwell <sfr-3FnU+UHB4dNDw9hX6IcOSA@public.gmane.org>
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Stephen Rothwell <sfr-3FnU+UHB4dNDw9hX6IcOSA@public.gmane.org> writes:

> Hi Eric,
>
>> As for missing cool tags shrug.  The people looking at my code didn't
>> feel like saying the magic words so I didn't include cool tags.
>
> Maybe you should push them ... these tags are not just "cool", they
> give less involved people some indications of what has happened in the
> life of a patch.

Etiquette is a good idea where it helps things flow smoothly.  Other
times like this standing on etiquette would have resulted in trivial
fixes for long standing issues not going anywhere.

Althogh I will keep it in mind in the future.

>> Which is a my long winded way of say it sounds like you are accusing me
>> of being irresponsible, and my way of saying that I have tested and
>
> I did not mean to accuse, there are reasons (as you have pointed out)
> that things get added late, or rewritten.

I really try to avoid those reasons but I missed it this round and the
buildbot did not manage to find the comibination with a build error
until the code hit linux-next :(

Eric
