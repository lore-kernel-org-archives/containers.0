From: Vasily Kulikov <segoon-cxoSlKxDwOJWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH review 1/6] userns: Avoid recursion in put_user_ns
Date: Mon, 28 Jan 2013 18:51:44 +0400
Message-ID: <20130128145144.GA4677@cachalot>
References: <87ehh8it9s.fsf@xmission.com>
 <877gn0it3t.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <877gn0it3t.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
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
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Fri, Jan 25, 2013 at 18:19 -0800, Eric W. Biederman wrote:
> 
> When freeing a deeply nested user namespace free_user_ns calls
> put_user_ns on it's parent which may in turn call free_user_ns again.
> When -fno-optimize-sibling-calls is passed to gcc one stack frame per
> user namespace is left on the stack, potentially overflowing the
> kernel stack.  CONFIG_FRAME_POINTER forces -fno-optimize-sibling-calls
> so we can't count on gcc to optimize this code.
> 
> Remove struct kref and use a plain atomic_t.  Making the code more
> flexible and easier to comprehend.  Make the loop in free_user_ns
> explict to guarantee that the stack does not overflow with
> CONFIG_FRAME_POINTER enabled.
> 
> I have tested this fix with a simple program that uses unshare to
> create a deeply nested user namespace structure and then calls exit.
> With 1000 nesteuser namespaces before this change running my test
> program causes the kernel to die a horrible death.  With 10,000,000
> nested user namespaces after this change my test program runs to
> completion and causes no harm.
> 
> Pointed-out-by: Vasily Kulikov <segoon-cxoSlKxDwOJWk0Htik3J/w@public.gmane.org>
> Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

Looks sane, thanks.

Acked-by: Vasily Kulikov <segoon-cxoSlKxDwOJWk0Htik3J/w@public.gmane.org>

The second bug I've noted in the same email (OOM) looks like should be
"fixed" by using memcg to limit kernel memory.  So, I'm fine with this
side of user_ns :)

-- 
Vasily Kulikov
http://www.openwall.com - bringing security into open computing environments
