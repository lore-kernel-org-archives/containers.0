From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Subject: Re: Two newbie questions on containers
Date: Tue, 11 Jan 2011 18:02:26 -0600
Message-ID: <1294790546.26638.36.camel@tp-t61>
References: <4D2CD4F7.9040006@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4D2CD4F7.9040006-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Timur Tabi <timur-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Hi Timur,

On Tue, 2011-01-11 at 16:08 -0600, Timur Tabi wrote:
> I'm in the process of learning about Linux containers, including cgroups, and
> the learning curve seems pretty steep to me.  So I have a couple newbie
> questions for all of you.  Any detailed answered are greatly appreciated.
> 
> 1) For the PowerPC architecture, is there anything that is "missing"?  I can't
> really tell how much of cgroups and lxc is architecture-specific, and there
> appears to be PowerPC support for both already.  I'd like to know if this
> another one of those areas, like KVM, where x86 is fully implemented and PowerPC
> support is lagging.

cgroups and the lxc utilities work just as well on powerpc as they do on
x86; there's nothing arch-specific about them.


> 2) Given a random device driver, like a driver for a serial port, is there an
> opportunity for the driver to be enhanced to support cgroups or lxc?  Doing a
> simple search of the kernel source code, I don't really see any drivers making
> calls into any cgroup code, so I don't understand how to restrict device access
> to a specific container or cgroup.

Not totally sure about this myself, but have you read
Documentation/cgroups/devices.txt in the kernel source yet?
