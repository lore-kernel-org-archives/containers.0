From: Alex Bligh <alex-rWA27mgs/Jz10XsdtD+oqA@public.gmane.org>
Subject: Re: Containers and threads
Date: Mon, 02 May 2011 17:55:49 +0100
Message-ID: <F6BF1C3F048A836E1B5A46D9@Ximines.local>
References: <55170C19BB117211B6D7FA1C@nimrod.local>
Reply-To: Alex Bligh <alex-rWA27mgs/Jz10XsdtD+oqA@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <55170C19BB117211B6D7FA1C-PdXK6nMiYlGE+EvaaNYduQ@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Alex Bligh <alex-rWA27mgs/Jz10XsdtD+oqA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org



--On 30 April 2011 11:05:21 +0100 Alex Bligh <alex-rWA27mgs/Jz10XsdtD+oqA@public.gmane.org> wrote:

> Is it possible for a process to have 2 threads, one of which does
> unshare(CLONE_NEWNET), but for them to be sharing the same memory
> space, and with the unsharing one doing fork() occasionally?

For future readers, the answer to this question is "yes", and if
you are doing things with 2 namespaces active, it's remarkably easy.

What you do need to know is to use the gettid() system call (no
glibc wrapper) to get the system tid (not pthreads tid) to as
the target to move interfaces between namespaces etc.

-- 
Alex Bligh
