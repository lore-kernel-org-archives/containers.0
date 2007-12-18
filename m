From: Tetsuo Handa <penguin-kernel-1yMVhJb1mP/7nzcFbJAaVXf5DAMn2ifp@public.gmane.org>
Subject: Re: [patch 1/2] [RFC] Simple tamper-proof device filesystem.
Date: Tue, 18 Dec 2007 09:03:23 +0900
Message-ID: <200712180003.lBI03N7F092396@www262.sakura.ne.jp>
References: <20071216080441.435456586@I-love.SAKURA.ne.jp>
	<20071216080628.061470932@I-love.SAKURA.ne.jp>
	<200712161944.HEI26071.MOtOFLVHFSQFOJ@I-love.SAKURA.ne.jp>
	<200712161956.BJE32406.FOOHtQJLMFOSVF@I-love.SAKURA.ne.jp>
	<20071217194802.GA14156@sergelap.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20071217194802.GA14156-6s5zFf/epYLPQpwDFJZrxKsjOiXwFzmk@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "\"\\\"Serge E. Hallyn\\\"\"" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Hello.

Serge E. Hallyn wrote:
> CAP_MKNOD will be removed from its capability
I think it is not enough because the root can rename/unlink device files
(mv /dev/sda1 /dev/tmp; mv /dev/sda2 /dev/sda1; mv /dev/tmp /dev/sda2).

> To use your approach, i guess we would have to use selinux (or tomoyo)
> to enforce that devices may only be created under /dev?
Everyone can use this filesystem alone.
But use with MAC (or whatever access control mechanisms that prevent
attackers from unmounting/overlaying this filesystem) is recomennded.
