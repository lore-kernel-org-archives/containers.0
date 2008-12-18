From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH 5/5] pid: use namespaced iteration on processes while
	managing priority
Date: Thu, 18 Dec 2008 09:46:46 -0800
Message-ID: <m13agl8jg9.fsf@frodo.ebiederm.org>
References: <1229618553-6348-1-git-send-email-gowrishankar.m@linux.vnet.ibm.com>
	<1229618553-6348-6-git-send-email-gowrishankar.m@linux.vnet.ibm.com>
	<20081218170509.GC13188@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20081218170509.GC13188-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> (Serge E. Hallyn's message of
	"Thu, 18 Dec 2008 11:05:09 -0600")
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
Cc: Gowrishankar M <gowrishankar.m-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Dave <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Sukadev <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Balbir <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

"Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> writes:

> Quoting Gowrishankar M (gowrishankar.m-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org):
>> From: Gowrishankar M <gomuthuk-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
>> 
>> At present we scan all processes in init namespace, while getting or setting
>> process priorities for a user. Incase of PID namespace, it leads to leak
>> priority to processes in other namespace.
>> 
>> Below patch proposes to use new macro controller to fix the boundary of
>> processes list in current namespace.
>> 
>> Signed-off-by: Gowrishankar M <gowrishankar.m-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
>
> Acked-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

Serge please look again. This has absolutely nothing to do with pids.
This is a problem to be solved with the user namespace.

Eric
