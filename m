From: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Subject: Re: ioctl CAP_LINUX_IMMUTABLE is checked in the wrong namespace
Date: Tue, 29 Apr 2014 11:37:20 -0700
Message-ID: <535FF160.3080404__20461.5569710315$1409358494$gmane$org@mit.edu>
References: <535FADDA.2070803@1h.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <535FADDA.2070803-108MBtLGafw@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Marian Marinov <public-mm-108MBtLGafw-wOFGN7rlS/M9smdsby/KFg@public.gmane.org>, public-containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA-wOFGN7rlS/M9smdsby/KFg@public.gmane.org, LXC development mailing-list <public-lxc-devel-cunTk1MwBs9qMoObBWhMNEqPaTDuhLve2LY78lusg7I-wOFGN7rlS/M9smdsby/KFg@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA-XMD5yJDbdMReXY1tMh2IBg@public.gmane.org" <public-linux-kernel-u79uwXL29TY76Z2rM5mHXA-wOFGN7rlS/M9smdsby/KFg@public.gmane.org>
List-Id: containers.vger.kernel.org




On 04/29/2014 06:49 AM, Marian Marinov wrote:
> Hello,
> when using user namespaces I found a bug in the capability checks done
> by ioctl.
> 
> If someone tries to use chattr +i while in a different user namespace it
> will get the following:
> 
> ioctl(3, EXT2_IOC_SETFLAGS, 0x7fffa4fedacc) = -1 EPERM (Operation not
> permitted)

NAK.  This is correct: you don't want users to be able to
unshare(CLONE_NEWUSER) and then start playing with the immutable bit.

--Andy
