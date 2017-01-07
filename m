From: Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
Subject: Re: [GIT PULL] namespace related fixes for 4.10-rc3
Date: Sat, 7 Jan 2017 06:40:13 +0000
Message-ID: <20170107064012.GI1555@ZenIV.linux.org.uk>
References: <87d1fzzbc2.fsf@xmission.com>
	<20170107062952.GH1555@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20170107062952.GH1555-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Sat, Jan 07, 2017 at 06:29:52AM +0000, Al Viro wrote:
> On Sat, Jan 07, 2017 at 06:30:05PM +1300, Eric W. Biederman wrote:
> 
> > Eric W. Biederman (3):
> >       mnt: Protect the mountpoint hashtable with mount_lock
> ACK
> 
> >       mnt: Tuck mounts under others instead of creating shadow/side mounts.
> 
> NAK; you have reintroduced put_mountpoint() outside of mount lock in there
> and you've got seriously confused umount side of the things.

PS: details are in my reply (admittedly, sent only ~20 minutes
before your pull request) to your patch.  Check Message-ID
<20170107050644.GA12074-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>

My apologies for not getting to it yesterday (the patch was posted a couple of
days ago, AFAICS) - I'd been off-net since Wednesday, just got back ;-/
