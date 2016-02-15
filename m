From: Philipp Wendler <ml-PRuqubkS1MrCxoAYUeDZubNAH6kLmebB@public.gmane.org>
Subject: Re: Using overlayfs in (unprivileged) namespace
Date: Mon, 15 Feb 2016 15:46:44 +0100
Message-ID: <56C1E4D4.5070400@philippwendler.de>
References: <56C1B0C6.6080806@philippwendler.de> <56C1BAE2.30209@kyup.com>
	<56C1C4D7.8030406@philippwendler.de> <56C1C674.3030705@kyup.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <56C1C674.3030705-6AxghH7DbtA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Hello,

Am 15.02.2016 um 13:37 schrieb Nikolay Borisov:
> On 02/15/2016 02:30 PM, Philipp Wendler wrote:
>> I have looked into ftrace now, but I didn't find a way how to see which
>> function is responsible for letting the rm fail.
>> The kernel documentation on ftrace is quite overwhelming, so maybe I
>> have missed something.
>> Do you have by chance a more specific pointer to what would help me?
> 
> If I were you I would run something along the lines of (inside the
> container):
> 
> trace-cmd record -p function_graph -F rm some-file
> 
> And then you would do :
> 
> trace-cmd report
> 
> and see the resulting call trace and quite possibly it might be failing
> in an ovl_* prefixed function.

Thanks, this was very helpful, and I know now that I was on a wrong path.

From the trace, I noticed that my Ubuntu kernel actually has an
additional legacy mode of overlayfs which I was using (unintentionally),
and which instead of creating a device node, creates a symlink and tries
to set the "trusted.overlay.whiteout" xattr on it, which fails.
So the failure has nothing to do with devices, sorry for the confusion.

The legacy mode got triggered by the "-t overlayfs" parameter to mount.
If I specify "-t overlay" instead, the normal mode gets used (which
seems to match the one in the vanilla kernel), and with this everything
appears to work nicely, regardless of whether the user namespace was
created by a privileged or an unprivileged user.

So sorry for the confusion and thank you very much for helping me
debugging this!

Greetings, Philipp
