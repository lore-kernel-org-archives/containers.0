From: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
Subject: Re: [RFC][PATCH 1/5] pid: Implement ns_of_pid
Date: Mon, 1 Dec 2008 12:24:22 -0800
Message-ID: <20081201202422.GD12493@us.ibm.com>
References: <20081126034242.GA23120@us.ibm.com> <20081126034442.GA23238@us.ibm.com> <20081127011910.GD13545@wavehammer.waldi.eu.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753024AbYLAUZJ@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20081127011910.GD13545@wavehammer.waldi.eu.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Bastian Blank <bastian@waldi.eu.org>, oleg@redhat.com, ebiederm@xmission.com, roland@redhat.com, containers@lists.osdl.org, linux-kernel@vger.kernel.org, xemul@openvz.org
List-Id: containers.vger.kernel.org

Bastian Blank [bastian@waldi.eu.org] wrote:
| On Tue, Nov 25, 2008 at 07:44:42PM -0800, Sukadev Bhattiprolu wrote:
| > +/* ns_of_pid returns the pid namespace in which the specified
| > + * pid was allocated.
| > + */
| > +static inline struct pid_namespace *ns_of_pid(struct pid *pid)
| > +{
| > +	struct pid_namespace *ns = NULL;
| > +	if (pid)
| > +		ns = pid->numbers[pid->level].ns;
| > +	return ns;
| > +}
| > +
| 
| When can the pid argument be null?

Soon after creation but more importantly, after detach_pid()
(release_task).

| 
| Bastian
| 
| -- 
| Another Armenia, Belgium ... the weak innocents who always seem to be
| located on a natural invasion route.
| 		-- Kirk, "Errand of Mercy", stardate 3198.4
