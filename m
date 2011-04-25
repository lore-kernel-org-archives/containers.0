From: Bastian Blank <bastian-yyjItF7Rl6lg9hUCZPvPmw@public.gmane.org>
Subject: Re: CLONE_NEWNET + unix domain sockets
Date: Mon, 25 Apr 2011 20:35:00 +0200
Message-ID: <20110425183459.GA29536@wavehammer.waldi.eu.org>
References: <6E3DBEA16997DE780A11C637@Ximines.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <6E3DBEA16997DE780A11C637-F+tRR8lnwRmNj9Bq2fkWzw@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On Mon, Apr 25, 2011 at 02:56:25PM +0100, Alex Bligh wrote:
> but I don't understand why, or what the semantics are for interaction
> between unshare(CLONE_NEWNET) and unix domain sockets. Any ideas?

AFAIK sharing unix sockets between network namespaces is supported since
2.6.36 or so.

Bastian

-- 
Killing is wrong.
		-- Losira, "That Which Survives", stardate unknown
