From: Bastian Blank <bastian@waldi.eu.org>
Subject: Re: [RFC][PATCH 1/5] pid: Implement ns_of_pid
Date: Tue, 2 Dec 2008 12:58:41 +0100
Message-ID: <20081202115841.GC1132@wavehammer.waldi.eu.org>
References: <20081126034242.GA23120@us.ibm.com> <20081126034442.GA23238@us.ibm.com> <20081127011910.GD13545@wavehammer.waldi.eu.org> <20081201202422.GD12493@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754153AbYLBL6x@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20081201202422.GD12493@us.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
Cc: oleg@redhat.com, ebiederm@xmission.com, roland@redhat.com, containers@lists.osdl.org, linux-kernel@vger.kernel.org, xemul@openvz.org
List-Id: containers.vger.kernel.org

On Mon, Dec 01, 2008 at 12:24:22PM -0800, Sukadev Bhattiprolu wrote:
> Bastian Blank [bastian@waldi.eu.org] wrote:
> | On Tue, Nov 25, 2008 at 07:44:42PM -0800, Sukadev Bhattiprolu wrote:
> | > +/* ns_of_pid returns the pid namespace in which the specified
> | > + * pid was allocated.
> | > + */
> | > +static inline struct pid_namespace *ns_of_pid(struct pid *pid)
> | > +{
> | > +	struct pid_namespace *ns = NULL;
> | > +	if (pid)
> | > +		ns = pid->numbers[pid->level].ns;
> | > +	return ns;
> | > +}
> | > +
> | When can the pid argument be null?
> Soon after creation but more importantly, after detach_pid()
> (release_task).

pid is a function argument and the function does not call detach_pid. So
please try again.

Bastian

-- 
Spock: The odds of surviving another attack are 13562190123 to 1, Captain.
