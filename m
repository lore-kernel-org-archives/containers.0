From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: namespaces compatibility list
Date: Tue, 06 Nov 2007 09:36:26 -0700
Message-ID: <m1ode772lx.fsf@ebiederm.dsl.xmission.com>
References: <47304729.8000309@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <47304729.8000309-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org> (Pavel Emelyanov's message of "Tue,
	06 Nov 2007 13:51:21 +0300")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org> writes:

> +2. Intentionnaly, two equal user ids in different user namespaces
> +   should not be equal from the VFS point of view. In other
> +   words, user 10 in one user namespace shouldn't have the same
> +   access permissions to files, beloging to user 10 in another
> +   namespace. But currently this is not so.

I don't know where this is going to land for a final call.
But if the pid namespace has a chance of landing under CONFIG_BROKEN
for the final stable release.

We seriously want to consider the user namespace for the same treatment.
We all seem to agree that it is incomplete.

Eric
