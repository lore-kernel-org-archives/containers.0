From: Grzegorz Nosek <root-AfQBxy1nhrQ00sYp1HPQUA@public.gmane.org>
Subject: Re: BUG in tty_open when using containers and ptrace
Date: Mon, 13 Jul 2009 21:30:58 +0200
Message-ID: <20090713193058.GL18617@megiteam.pl>
References: <d06d0dd6a4ddf760bea53291c048e291@[::1]>
	<20090413142038.GB13007@us.ibm.com>
	<20090704132851.GA16373@megiteam.pl>
	<20090704143412.GA27523@megiteam.pl>
	<20090708105417.GA16833@megiteam.pl>
	<20090711193055.GA11303@megiteam.pl>
	<20090711200133.GB11303@megiteam.pl>
	<20090711231935.6ff59796@lxorguk.ukuu.org.uk>
	<20090712074932.GA17291@megiteam.pl>
	<20090713190211.GA4208@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090713190211.GA4208-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>, lxc-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: containers.vger.kernel.org

On Mon, Jul 13, 2009 at 02:02:11PM -0500, Serge E. Hallyn wrote:
> I've tried but failed to reproduce.  Do you have a script or a more
> precise recipe you can share?

I do have a script but all it does is starting and shutting down
a container in a loop. I can strip down and publish the virtualbox vm
image somewhere, if that helps.

Best regards,
 Grzegorz Nosek
