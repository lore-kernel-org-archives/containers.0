From: Nikolay Borisov <kernel-6AxghH7DbtA@public.gmane.org>
Subject: Re: Using overlayfs in (unprivileged) namespace
Date: Mon, 15 Feb 2016 14:37:08 +0200
Message-ID: <56C1C674.3030705@kyup.com>
References: <56C1B0C6.6080806@philippwendler.de> <56C1BAE2.30209@kyup.com>
	<56C1C4D7.8030406@philippwendler.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <56C1C4D7.8030406-PRuqubkS1MrCxoAYUeDZubNAH6kLmebB@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Philipp Wendler <ml-PRuqubkS1MrCxoAYUeDZubNAH6kLmebB@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org



On 02/15/2016 02:30 PM, Philipp Wendler wrote:
> I have looked into ftrace now, but I didn't find a way how to see which
> function is responsible for letting the rm fail.
> The kernel documentation on ftrace is quite overwhelming, so maybe I
> have missed something.
> Do you have by chance a more specific pointer to what would help me?

If I were you I would run something along the lines of (inside the
container):

trace-cmd record -p function_graph -F rm some-file

And then you would do :

trace-cmd report

and see the resulting call trace and quite possibly it might be failing
in an ovl_* prefixed function.
