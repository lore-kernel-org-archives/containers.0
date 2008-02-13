From: "Paul Menage" <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 4/4] The control group itself
Date: Tue, 12 Feb 2008 18:17:14 -0800
Message-ID: <6599ad830802121817n7713fa85h51aedf4df74aa764@mail.gmail.com>
References: <47AAFFF2.9030804@openvz.org> <47AB013B.8060502@openvz.org>
	<20080211173830.GA22160@sergelap.ibm.com>
	<47B174B2.5010500@openvz.org>
	<20080212172134.GA12177@sergelap.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080212172134.GA12177-6s5zFf/epYLPQpwDFJZrxKsjOiXwFzmk@public.gmane.org>
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
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

On Feb 12, 2008 9:21 AM, Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> wrote:
>
> Paul (actually both Menage and Jackson :) do you have an opinion on
> this?  Are there sites which eg do 'chown -R some_user_id /cgroup/cpusets/'
> to have some non-root user be able to dole out cpusets?

We (Google) currently only do that for the tasks file, to allow users
to move their processes between cpusets/groups that they own.

> Is there any
> way it would be ok to have cgroup_file_write() check for CAP_SYS_ADMIN?

Sure, we could have flags in the subsys object for this kind of thing
that let particular subsystems request this.

Paul
