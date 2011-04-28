From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: CLONE_NEWNET + unix domain sockets
Date: Thu, 28 Apr 2011 13:03:46 -0700
Message-ID: <m1ei4mdty5.fsf@fess.ebiederm.org>
References: <6E3DBEA16997DE780A11C637@Ximines.local>
	<20110425183459.GA29536@wavehammer.waldi.eu.org>
	<E5092261EC5F5ABA2AE6E7EE@Ximines.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <E5092261EC5F5ABA2AE6E7EE-F+tRR8lnwRmNj9Bq2fkWzw@public.gmane.org> (Alex Bligh's message of
	"Mon, 25 Apr 2011 19:54:10 +0100")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Alex Bligh <alex-rWA27mgs/Jz10XsdtD+oqA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Bastian Blank <bastian-yyjItF7Rl6lg9hUCZPvPmw@public.gmane.org>
List-Id: containers.vger.kernel.org

Alex Bligh <alex-rWA27mgs/Jz10XsdtD+oqA@public.gmane.org> writes:

> --On 25 April 2011 20:35:00 +0200 Bastian Blank <bastian-yyjItF7Rl6lg9hUCZPvPmw@public.gmane.org> 
> wrote:
>
>> On Mon, Apr 25, 2011 at 02:56:25PM +0100, Alex Bligh wrote:
>>> but I don't understand why, or what the semantics are for interaction
>>> between unshare(CLONE_NEWNET) and unix domain sockets. Any ideas?
>>
>> AFAIK sharing unix sockets between network namespaces is supported since
>> 2.6.36 or so.
>
> I'm using 2.6.32-28-generic, and I'm doing
> 	fork()
> 	listen()
> 	unshare(CLONE_NEWNET)
> 	...
> 	accept()
>
> and it seems to be working. Is that forward compatible?

Yes.

Eric
